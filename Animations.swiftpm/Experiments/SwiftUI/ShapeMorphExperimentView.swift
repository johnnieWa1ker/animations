import SwiftUI

struct ShapeMorphExperimentView: View {
    @State private var isAnimating = false
    @State private var widthScale = 1.0
    @State private var heightScale = 1.0
    @State private var pointTravel = 0.08
    @State private var speed = 0.8
    @State private var showsPoints = true

    var body: some View {
        VStack(spacing: 18) {
            ShapeMorphPreviewView(
                isAnimating: isAnimating,
                widthScale: widthScale,
                heightScale: heightScale,
                pointTravel: pointTravel,
                speed: speed,
                showsPoints: showsPoints
            )

            VStack(spacing: 16) {
                Toggle("Animate shape", isOn: $isAnimating)
                    .font(.headline)

                Toggle("Show points", isOn: $showsPoints)
                    .font(.headline)

                ControlSliderView(
                    title: "Width",
                    value: $widthScale,
                    range: 0.55 ... 1.28,
                    format: .number.precision(.fractionLength(2))
                )

                ControlSliderView(
                    title: "Height",
                    value: $heightScale,
                    range: 0.55 ... 1.28,
                    format: .number.precision(.fractionLength(2))
                )

                ControlSliderView(
                    title: "Point travel",
                    value: $pointTravel,
                    range: 0 ... 0.32,
                    format: .number.precision(.fractionLength(2))
                )

                ControlSliderView(
                    title: "Speed",
                    value: $speed,
                    range: 0.15 ... 1.7,
                    format: .number.precision(.fractionLength(2))
                )
            }
            .padding(16)
            .background(.regularMaterial, in: .rect(cornerRadius: 16))
        }
    }
}

private struct ShapeMorphPreviewView: View {
    private let baseSize = CGSize(width: 373.43, height: 323.86)
    private let shapeColor = Color(red: 0.522, green: 0.149, blue: 1).opacity(0.2)

    let isAnimating: Bool
    let widthScale: Double
    let heightScale: Double
    let pointTravel: Double
    let speed: Double
    let showsPoints: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            let seconds = timeline.date.timeIntervalSinceReferenceDate
            let phase = isAnimating ? seconds * speed : 0

            GeometryReader { proxy in
                let targetSize = CGSize(
                    width: baseSize.width * widthScale,
                    height: baseSize.height * heightScale
                )
                let previewSize = CGSize(
                    width: max(proxy.size.width - 28, 1),
                    height: max(proxy.size.height - 28, 1)
                )
                let fitScale = min(1, previewSize.width / targetSize.width, previewSize.height / targetSize.height)
                let displaySize = CGSize(
                    width: targetSize.width * fitScale,
                    height: targetSize.height * fitScale
                )

                ZStack {
                    PreviewGridView()

                    MorphingPurpleShape(phase: phase, pointTravel: pointTravel)
                        .fill(shapeColor)
                        .overlay {
                            MorphingPurpleShape(phase: phase, pointTravel: pointTravel)
                                .stroke(.purple.opacity(0.42), lineWidth: 1.5)
                        }
                        .frame(width: displaySize.width, height: displaySize.height)
                        .animation(.spring(response: 0.5, dampingFraction: 0.76), value: widthScale)
                        .animation(.spring(response: 0.5, dampingFraction: 0.76), value: heightScale)
                        .blur(radius: 30)

                    if showsPoints {
                        MorphingShapePointsView(
                            phase: phase,
                            pointTravel: pointTravel,
                            size: displaySize
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .topLeading) {
                    SizeBadgeView(size: targetSize)
                        .padding(12)
                }
            }
        }
        .frame(height: 360)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: .rect(cornerRadius: 18))
    }
}

private struct MorphingPurpleShape: Shape {
    var phase: Double
    var pointTravel: Double

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(phase, pointTravel) }
        set {
            phase = newValue.first
            pointTravel = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let points = MorphingShapeGeometry.points(
            in: rect,
            phase: phase,
            pointTravel: pointTravel
        )

        var path = Path()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        path.closeSubpath()
        return path
    }
}

private struct MorphingShapePointsView: View {
    let phase: Double
    let pointTravel: Double
    let size: CGSize

    var body: some View {
        ZStack {
            ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                Circle()
                    .fill(.purple)
                    .frame(width: 9, height: 9)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.75), lineWidth: 1)
                    }
                    .position(point)
                    .accessibilityLabel("Point \(index + 1)")
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }

    private var points: [CGPoint] {
        MorphingShapeGeometry.points(
            in: CGRect(origin: .zero, size: size),
            phase: phase,
            pointTravel: pointTravel
        )
    }
}

private enum MorphingShapeGeometry {
    static func points(
        in rect: CGRect,
        phase: Double,
        pointTravel: Double
    ) -> [CGPoint] {
        anchors.enumerated().map { index, anchor in
            let wave = phase + Double(index) * 1.08
            let amplitude = min(rect.width, rect.height) * pointTravel
            let xOffset = phase == 0 ? 0 : cos(wave * 1.13) * amplitude * anchor.xWeight
            let yOffset = phase == 0 ? 0 : sin(wave * 0.91) * amplitude * anchor.yWeight

            return CGPoint(
                x: rect.minX + rect.width * anchor.x + xOffset,
                y: rect.minY + rect.height * anchor.y + yOffset
            )
        }
    }

    private static let anchors: [MorphingAnchor] = [
        MorphingAnchor(x: 0.00, y: 0.64, xWeight: 0.20, yWeight: 0.24),
        MorphingAnchor(x: 0.50, y: 0.38, xWeight: 0.24, yWeight: 0.16),
        MorphingAnchor(x: 0.82, y: 0.00, xWeight: 0.14, yWeight: 0.24),
        MorphingAnchor(x: 1.00, y: 1.00, xWeight: 0.16, yWeight: 0.18),
        MorphingAnchor(x: 0.56, y: 0.74, xWeight: 0.24, yWeight: 0.18)
    ]
}

private struct MorphingAnchor {
    let x: Double
    let y: Double
    let xWeight: Double
    let yWeight: Double
}

private struct PreviewGridView: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            let step: CGFloat = 28

            for x in stride(from: CGFloat.zero, through: size.width, by: step) {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }

            for y in stride(from: CGFloat.zero, through: size.height, by: step) {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }

            context.stroke(path, with: .color(.secondary.opacity(0.12)), lineWidth: 1)
        }
    }
}

private struct SizeBadgeView: View {
    let size: CGSize

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.up.left.and.arrow.down.right")

            Text(size.width, format: .number.precision(.fractionLength(0)))

            Text("x")

            Text(size.height, format: .number.precision(.fractionLength(0)))
        }
        .font(.caption.monospacedDigit().bold())
        .foregroundStyle(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.thinMaterial, in: .capsule)
    }
}

#Preview {
    ShapeMorphExperimentView()
}
