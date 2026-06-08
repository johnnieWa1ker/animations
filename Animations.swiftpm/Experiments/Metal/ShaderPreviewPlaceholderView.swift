import SwiftUI

struct ShaderPreviewPlaceholderView: View {
    @State private var intensity = 0.42
    @State private var speed = 0.65
    @State private var showsGrid = true

    var body: some View {
        VStack(spacing: 18) {
            TimelineView(.animation) { timeline in
                let seconds = timeline.date.timeIntervalSinceReferenceDate
                ShaderLikePreviewView(
                    seconds: seconds,
                    intensity: intensity,
                    speed: speed,
                    showsGrid: showsGrid
                )
            }
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: .rect(cornerRadius: 18))

            VStack(spacing: 16) {
                Toggle("Show reference grid", isOn: $showsGrid)
                    .font(.headline)

                ControlSliderView(
                    title: "Intensity",
                    value: $intensity,
                    range: 0.05 ... 1,
                    format: .number.precision(.fractionLength(2))
                )

                ControlSliderView(
                    title: "Speed",
                    value: $speed,
                    range: 0.1 ... 1.5,
                    format: .number.precision(.fractionLength(2))
                )
            }
            .padding(16)
            .background(.regularMaterial, in: .rect(cornerRadius: 16))
        }
    }
}

private struct ShaderLikePreviewView: View {
    let seconds: TimeInterval
    let intensity: Double
    let speed: Double
    let showsGrid: Bool

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            context.fill(
                Path(rect),
                with: .linearGradient(
                    Gradient(colors: [
                        .indigo.opacity(0.95),
                        .cyan.opacity(0.72),
                        .black.opacity(0.88)
                    ]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: size.width, y: size.height)
                )
            )

            if showsGrid {
                drawGrid(in: rect, context: &context)
            }

            for index in 0 ..< 7 {
                let phase = seconds * speed + Double(index) * 0.58
                let x = size.width * (0.12 + 0.78 * ((sin(phase) + 1) / 2))
                let y = size.height * (0.16 + 0.68 * ((cos(phase * 0.82) + 1) / 2))
                let radius = CGFloat(34 + intensity * 70)
                let ellipse = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)

                context.fill(
                    Path(ellipseIn: ellipse),
                    with: .radialGradient(
                        Gradient(colors: [.white.opacity(0.32), .cyan.opacity(0.16), .clear]),
                        center: CGPoint(x: x, y: y),
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
        }
        .clipShape(.rect(cornerRadius: 18))
        .overlay(alignment: .topLeading) {
            Label("Canvas stand-in for Metal", systemImage: "cpu")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.88))
                .padding(10)
        }
    }

    private func drawGrid(in rect: CGRect, context: inout GraphicsContext) {
        var path = Path()
        let step: CGFloat = 28

        for x in stride(from: rect.minX, through: rect.maxX, by: step) {
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
        }

        for y in stride(from: rect.minY, through: rect.maxY, by: step) {
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }

        context.stroke(path, with: .color(.white.opacity(0.1)), lineWidth: 1)
    }
}
