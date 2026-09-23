import SwiftUI

/// Two material images and a bounded heat history, applied to live SwiftUI content.
struct IceSurface: View {
    private struct RunID: Hashable {
        var active: Bool
        var width: CGFloat
        var height: CGFloat
    }
    let settings: IceSettings
    let isRunning: Bool
    @State private var simulation = IceSimulation()

    var body: some View {
        GeometryReader { geometry in
            IceBackdrop()
                .compositingGroup()
                .layerEffect(
                    ShaderLibrary.iceGlass(
                        .float2(geometry.size), .float(simulation.season),
                        .float(settings.thickness), .image(Image("IceColor")),
                        .image(Image("IceRelief")), .floatArray(simulation.shaderTouches)
                    ),
                    maxSampleOffset: CGSize(width: geometry.size.width * 0.3,
                                            height: geometry.size.height * 0.3)
                )
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard geometry.size.width > 0, geometry.size.height > 0 else { return }
                        simulation.finger = SIMD2(
                            Float(min(max(value.location.x / geometry.size.width, 0), 1)),
                            Float(min(max(value.location.y / geometry.size.height, 0), 1)))
                    }
                    .onEnded { _ in simulation.finger = nil })
                .task(id: RunID(active: isRunning, width: geometry.size.width, height: geometry.size.height)) {
                    guard isRunning else { simulation.finger = nil; return }
                    var previous = ContinuousClock.now
                    while !Task.isCancelled {
                        do { try await Task.sleep(for: .milliseconds(33)) }
                        catch { return }
                        let now = ContinuousClock.now
                        let elapsed = previous.duration(to: now)
                        previous = now
                        let dt = Float(elapsed.components.seconds)
                            + Float(elapsed.components.attoseconds) / 1e18
                        if simulation.needsAdvance(settings: settings) {
                            simulation.advance(dt: min(dt, 0.1), settings: settings,
                                aspect: Float(geometry.size.width / max(geometry.size.height, 1)))
                        }
                    }
                }
                .onChange(of: settings.resetID) { _, _ in simulation.reset() }
                .onDisappear { simulation.finger = nil }
        }
    }
}

/// Fixed 20 Hz deposits make melting independent of display/gesture callback rate.
struct IceSimulation {
    struct Deposit {
        var point: SIMD2<Float>
        var strength: Float
        var age: Float = 0
    }
    var season: Float = 0
    var finger: SIMD2<Float>?
    private(set) var deposits: [Deposit] = []
    private var touchClock: Float = 0

    var shaderTouches: [Float] {
        deposits.flatMap { [$0.point.x, $0.point.y, $0.strength, $0.age] }
    }

    @MainActor
    func needsAdvance(settings: IceSettings) -> Bool {
        season != (settings.melts ? 0 : 1) || finger != nil ||
            (settings.refreezes && !deposits.isEmpty)
    }

    mutating func reset() {
        season = 0
        deposits.removeAll(keepingCapacity: true)
        touchClock = 0
        finger = nil
    }

    @MainActor
    mutating func advance(dt: Float, settings: IceSettings, aspect: Float) {
        let target: Float = settings.melts ? 0 : 1
        let speed: Float = settings.melts ? 0.35 : 0.24
        season += min(abs(target - season), dt * speed) * (target >= season ? 1 : -1)
        if settings.refreezes {
            for index in deposits.indices { deposits[index].age += dt }
            deposits.removeAll { $0.age > 7 }
        }
        touchClock += dt
        guard let finger else { touchClock = 0; return }
        while touchClock >= 0.05 {
            touchClock -= 0.05
            deposit(at: finger, aspect: aspect)
        }
    }

    private mutating func deposit(at point: SIMD2<Float>, aspect: Float) {
        let nearby = deposits.firstIndex { distanceSquared($0.point, point, aspect) < 0.0004 }
        // At capacity merge into the nearest sample instead of erasing old holes.
        let nearest = deposits.count == 160 ? deposits.indices.min {
            distanceSquared(deposits[$0].point, point, aspect) < distanceSquared(deposits[$1].point, point, aspect)
        } : nil
        if let index = nearby ?? nearest {
            let old = deposits[index]
            let remaining = old.strength * exp(-max(0, old.age - 2) * 1.4)
            deposits[index].strength = min(1.6, remaining + 0.2)
            deposits[index].age = 0
        } else {
            deposits.append(Deposit(point: point, strength: 0.2))
        }
    }

    private func distanceSquared(_ a: SIMD2<Float>, _ b: SIMD2<Float>, _ aspect: Float) -> Float {
        let d = (a - b) * SIMD2(aspect, 1)
        return d.x * d.x + d.y * d.y
    }
}
