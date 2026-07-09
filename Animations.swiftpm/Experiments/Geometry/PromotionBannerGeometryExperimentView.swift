import SwiftUI

struct PromotionBannerGeometryExperimentView: View {
    @State private var pointerX = 180.0
    @State private var cornerRadius = 12.0
    @State private var pointerHalfWidth = 17.0
    @State private var pointerHeight = 9.0
    @State private var pointerBaseHandle = 13.0 / 17.0
    @State private var pointerPeakHandle = 3.0 / 17.0
    @State private var edgeRetractionDistance = 24.0
    @State private var showsAttachmentPoints = true
    @State private var showsTangents = true
    @State private var showsSvgReference = true

    var body: some View {
        VStack(spacing: 18) {
            PromotionBannerGeometryPreview(
                configuration: configuration,
                showsAttachmentPoints: showsAttachmentPoints,
                showsTangents: showsTangents,
                showsSvgReference: showsSvgReference
            )

            VStack(spacing: 16) {
                Toggle("Attachment points", isOn: $showsAttachmentPoints)
                    .font(.headline)

                Toggle("Tangents", isOn: $showsTangents)
                    .font(.headline)

                Toggle("SVG reference", isOn: $showsSvgReference)
                    .font(.headline)

                ControlSliderView(
                    title: "Pointer X",
                    value: $pointerX,
                    range: -40 ... 400,
                    format: .number.precision(.fractionLength(0))
                )

                ControlSliderView(
                    title: "Corner radius",
                    value: $cornerRadius,
                    range: 0 ... 28,
                    format: .number.precision(.fractionLength(0))
                )

                ControlSliderView(
                    title: "Pointer half width",
                    value: $pointerHalfWidth,
                    range: 6 ... 34,
                    format: .number.precision(.fractionLength(0))
                )

                ControlSliderView(
                    title: "Pointer height",
                    value: $pointerHeight,
                    range: 0 ... 18,
                    format: .number.precision(.fractionLength(0))
                )

                ControlSliderView(
                    title: "Base handle",
                    value: $pointerBaseHandle,
                    range: 0.1 ... 1.1,
                    format: .number.precision(.fractionLength(2))
                )

                ControlSliderView(
                    title: "Peak handle",
                    value: $pointerPeakHandle,
                    range: 0.04 ... 0.7,
                    format: .number.precision(.fractionLength(2))
                )

                ControlSliderView(
                    title: "Edge retraction",
                    value: $edgeRetractionDistance,
                    range: 4 ... 64,
                    format: .number.precision(.fractionLength(0))
                )
            }
            .padding(16)
            .background(.regularMaterial, in: .rect(cornerRadius: 16))
        }
    }

    private var configuration: PracticeBannerConfiguration {
        PracticeBannerConfiguration(
            pointerX: CGFloat(pointerX),
            cornerRadius: CGFloat(cornerRadius),
            pointerHalfWidth: CGFloat(pointerHalfWidth),
            pointerHeight: CGFloat(pointerHeight),
            pointerBaseHandle: CGFloat(pointerBaseHandle),
            pointerPeakHandle: CGFloat(pointerPeakHandle),
            edgeRetractionDistance: CGFloat(edgeRetractionDistance)
        )
    }
}

private struct PromotionBannerGeometryPreview: View {
    let configuration: PracticeBannerConfiguration
    let showsAttachmentPoints: Bool
    let showsTangents: Bool
    let showsSvgReference: Bool

    var body: some View {
        GeometryReader { proxy in
            let bannerSize = CGSize(
                width: min(proxy.size.width - 40, 420),
                height: PracticeBannerConfiguration.totalHeight
            )
            let rect = CGRect(origin: .zero, size: bannerSize)
            let diagnostics = PracticePromotionBannerShape.diagnostics(
                in: rect,
                configuration: configuration
            )

            ZStack {
                GeometryGridView()

                VStack(spacing: 18) {
                    ZStack {
                        PracticePromotionBannerShape(configuration: configuration)
                            .fill(.orange.opacity(0.22))
                            .overlay {
                                PracticePromotionBannerShape(configuration: configuration)
                                    .stroke(.orange, lineWidth: 2)
                            }

                        if showsSvgReference {
                            SvgPointerReferenceShape(configuration: configuration)
                                .stroke(.pink, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                        }

                        if showsTangents {
                            TangentOverlayView(diagnostics: diagnostics)
                        }

                        if showsAttachmentPoints {
                            AttachmentPointsOverlayView(diagnostics: diagnostics)
                        }
                    }
                    .frame(width: bannerSize.width, height: bannerSize.height)
                    .animation(.snappy(duration: 0.22), value: configuration)

                    HStack(spacing: 12) {
                        GeometryBadge(title: "start", value: diagnostics.start.point.x)
                        GeometryBadge(title: "peak", value: diagnostics.peak.x)
                        GeometryBadge(title: "end", value: diagnostics.end.point.x)
                        GeometryBadge(title: "retract", value: diagnostics.pointer.retractProgress)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 320)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: .rect(cornerRadius: 18))
    }
}

// MARK: - Practice Shape

private struct PracticePromotionBannerShape: Shape {
    var configuration: PracticeBannerConfiguration

    var animatableData: PracticeBannerConfiguration.AnimatableData {
        get { configuration.animatableData }
        set { configuration.animatableData = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let metrics = PracticeBannerMetrics(rect: rect, configuration: configuration)
        let pointer = Pointer(metrics: metrics)
        let leftBoundaryPoint = Self.topBoundaryPoint(at: rect.minX, metrics: metrics).point
        var path = Path()

        path.move(to: leftBoundaryPoint)
        addTopEdge(to: &path, metrics: metrics, pointer: pointer)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - metrics.cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.maxX - metrics.cornerRadius, y: rect.maxY - metrics.cornerRadius),
            radius: metrics.cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX + metrics.cornerRadius, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + metrics.cornerRadius, y: rect.maxY - metrics.cornerRadius),
            radius: metrics.cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addLine(to: leftBoundaryPoint)
        path.closeSubpath()

        return path
    }

    static func diagnostics(
        in rect: CGRect,
        configuration: PracticeBannerConfiguration
    ) -> PracticeBannerDiagnostics {
        let metrics = PracticeBannerMetrics(rect: rect, configuration: configuration)
        let pointer = Pointer(metrics: metrics)
        let startX = (pointer.centerX - pointer.halfWidth).clamped(to: rect.minX ... rect.maxX)
        let endX = (pointer.centerX + pointer.halfWidth).clamped(to: rect.minX ... rect.maxX)
        let start = topBoundaryPoint(at: startX, metrics: metrics)
        let end = topBoundaryPoint(at: endX, metrics: metrics)
        let peak = CGPoint(x: pointer.centerX, y: metrics.topY - pointer.height)

        return PracticeBannerDiagnostics(
            pointer: pointer,
            start: start,
            peak: peak,
            end: end
        )
    }

    private func addTopEdge(
        to path: inout Path,
        metrics: PracticeBannerMetrics,
        pointer: Pointer
    ) {
        guard pointer.height > .zero, pointer.halfWidth > .zero else {
            addTopBoundarySegment(
                to: &path,
                metrics: metrics,
                from: metrics.rect.minX,
                to: metrics.rect.maxX
            )
            return
        }

        let startX = (pointer.centerX - pointer.halfWidth).clamped(to: metrics.rect.minX ... metrics.rect.maxX)
        let endX = (pointer.centerX + pointer.halfWidth).clamped(to: metrics.rect.minX ... metrics.rect.maxX)

        guard endX - startX > 1 else {
            addTopBoundarySegment(
                to: &path,
                metrics: metrics,
                from: metrics.rect.minX,
                to: metrics.rect.maxX
            )
            return
        }

        // Exercise: replace these three calls with your own segmentation strategy.
        addTopBoundarySegment(to: &path, metrics: metrics, from: metrics.rect.minX, to: startX)
        addPointer(to: &path, metrics: metrics, pointer: pointer, startX: startX, endX: endX)
        addTopBoundarySegment(to: &path, metrics: metrics, from: endX, to: metrics.rect.maxX)
    }

    private func addTopBoundarySegment(
        to path: inout Path,
        metrics: PracticeBannerMetrics,
        from startX: CGFloat,
        to endX: CGFloat
    ) {
        var currentX = startX.clamped(to: metrics.rect.minX ... metrics.rect.maxX)
        let targetX = endX.clamped(to: metrics.rect.minX ... metrics.rect.maxX)
        let leftArcEndX = metrics.rect.minX + metrics.cornerRadius
        let rightArcStartX = metrics.rect.maxX - metrics.cornerRadius

        guard targetX > currentX else { return }

        if currentX < leftArcEndX {
            let segmentEndX = min(targetX, leftArcEndX)
            addTopArc(to: &path, metrics: metrics, from: currentX, to: segmentEndX, centerX: leftArcEndX)
            currentX = segmentEndX
        }

        guard targetX > currentX else { return }

        if currentX < rightArcStartX {
            let segmentEndX = min(targetX, rightArcStartX)
            path.addLine(to: Self.topBoundaryPoint(at: segmentEndX, metrics: metrics).point)
            currentX = segmentEndX
        }

        guard targetX > currentX else { return }

        addTopArc(to: &path, metrics: metrics, from: currentX, to: targetX, centerX: rightArcStartX)
    }

    private func addTopArc(
        to path: inout Path,
        metrics: PracticeBannerMetrics,
        from startX: CGFloat,
        to endX: CGFloat,
        centerX: CGFloat
    ) {
        let center = CGPoint(x: centerX, y: metrics.topY + metrics.cornerRadius)
        let startAngle = Self.topArcAngle(at: startX, center: center, cornerRadius: metrics.cornerRadius)
        let endAngle = Self.topArcAngle(at: endX, center: center, cornerRadius: metrics.cornerRadius)

        path.addArc(
            center: center,
            radius: metrics.cornerRadius,
            startAngle: .radians(Double(startAngle)),
            endAngle: .radians(Double(endAngle)),
            clockwise: false
        )
    }

    private func addPointer(
        to path: inout Path,
        metrics: PracticeBannerMetrics,
        pointer: Pointer,
        startX: CGFloat,
        endX: CGFloat
    ) {
        let start = Self.topBoundaryPoint(at: startX, metrics: metrics)
        let end = Self.topBoundaryPoint(at: endX, metrics: metrics)
        let peak = CGPoint(x: pointer.centerX, y: metrics.topY - pointer.height)
        let leftSpan = peak.x - start.point.x
        let rightSpan = end.point.x - peak.x
        let minimumPeakControl = pointer.height * 0.28

        // Exercise: this is the shape's personality. Try changing handle ratios first.
        path.addCurve(
            to: peak,
            control1: start.point.offset(
                by: start.tangent,
                distance: max(leftSpan, 1) * metrics.configuration.pointerBaseHandle
            ),
            control2: CGPoint(
                x: peak.x - max(leftSpan * metrics.configuration.pointerPeakHandle, minimumPeakControl),
                y: peak.y
            )
        )
        path.addCurve(
            to: end.point,
            control1: CGPoint(
                x: peak.x + max(rightSpan * metrics.configuration.pointerPeakHandle, minimumPeakControl),
                y: peak.y
            ),
            control2: end.point.offset(
                by: end.tangent,
                distance: -max(rightSpan, 1) * metrics.configuration.pointerBaseHandle
            )
        )
    }

    private static func topBoundaryPoint(
        at positionX: CGFloat,
        metrics: PracticeBannerMetrics
    ) -> BoundaryPoint {
        let clampedX = positionX.clamped(to: metrics.rect.minX ... metrics.rect.maxX)
        let leftCornerEndX = metrics.rect.minX + metrics.cornerRadius
        let rightCornerStartX = metrics.rect.maxX - metrics.cornerRadius

        if clampedX < leftCornerEndX {
            return arcBoundaryPoint(
                at: clampedX,
                center: CGPoint(x: leftCornerEndX, y: metrics.topY + metrics.cornerRadius),
                cornerRadius: metrics.cornerRadius
            )
        } else if clampedX > rightCornerStartX {
            return arcBoundaryPoint(
                at: clampedX,
                center: CGPoint(x: rightCornerStartX, y: metrics.topY + metrics.cornerRadius),
                cornerRadius: metrics.cornerRadius
            )
        } else {
            return BoundaryPoint(
                point: CGPoint(x: clampedX, y: metrics.topY),
                tangent: CGVector(dx: 1, dy: 0)
            )
        }
    }

    private static func arcBoundaryPoint(
        at positionX: CGFloat,
        center: CGPoint,
        cornerRadius: CGFloat
    ) -> BoundaryPoint {
        let dx = arcOffsetX(for: positionX, centerX: center.x, cornerRadius: cornerRadius)
        let dy = topArcOffsetY(for: dx, cornerRadius: cornerRadius)
        let angle = normalizedTopArcAngle(atan2(dy, dx))

        return BoundaryPoint(
            point: CGPoint(x: center.x + dx, y: center.y + dy),
            tangent: CGVector(dx: -sin(angle), dy: cos(angle))
        )
    }

    private static func topArcAngle(
        at positionX: CGFloat,
        center: CGPoint,
        cornerRadius: CGFloat
    ) -> CGFloat {
        let dx = arcOffsetX(for: positionX, centerX: center.x, cornerRadius: cornerRadius)
        let dy = topArcOffsetY(for: dx, cornerRadius: cornerRadius)
        return normalizedTopArcAngle(atan2(dy, dx))
    }

    private static func arcOffsetX(
        for positionX: CGFloat,
        centerX: CGFloat,
        cornerRadius: CGFloat
    ) -> CGFloat {
        (positionX - centerX).clamped(to: -cornerRadius ... cornerRadius)
    }

    private static func topArcOffsetY(
        for offsetX: CGFloat,
        cornerRadius: CGFloat
    ) -> CGFloat {
        -sqrt(max(cornerRadius * cornerRadius - offsetX * offsetX, .zero))
    }

    private static func normalizedTopArcAngle(_ angle: CGFloat) -> CGFloat {
        angle <= .zero ? angle + .pi * 2 : angle
    }
}

// MARK: - Debug Layers

private struct AttachmentPointsOverlayView: View {
    let diagnostics: PracticeBannerDiagnostics

    var body: some View {
        ZStack {
            marker(diagnostics.start.point, color: .blue)
            marker(diagnostics.peak, color: .pink)
            marker(diagnostics.end.point, color: .green)
        }
    }

    private func marker(_ point: CGPoint, color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .overlay {
                Circle().stroke(.white, lineWidth: 1)
            }
            .position(point)
    }
}

private struct TangentOverlayView: View {
    let diagnostics: PracticeBannerDiagnostics

    var body: some View {
        Canvas { context, _ in
            drawTangent(from: diagnostics.start, color: .blue, context: &context)
            drawTangent(from: diagnostics.end, color: .green, context: &context)
        }
        .allowsHitTesting(false)
    }

    private func drawTangent(
        from point: BoundaryPoint,
        color: Color,
        context: inout GraphicsContext
    ) {
        let length: CGFloat = 30
        let start = point.point.offset(by: point.tangent, distance: -length / 2)
        let end = point.point.offset(by: point.tangent, distance: length / 2)
        var path = Path()

        path.move(to: start)
        path.addLine(to: end)
        context.stroke(path, with: .color(color.opacity(0.8)), lineWidth: 2)
    }
}

private struct SvgPointerReferenceShape: Shape {
    let configuration: PracticeBannerConfiguration

    func path(in rect: CGRect) -> Path {
        let metrics = PracticeBannerMetrics(rect: rect, configuration: configuration)
        let pointer = Pointer(metrics: metrics)
        let startX = pointer.centerX - configuration.pointerHalfWidth
        let endX = pointer.centerX + configuration.pointerHalfWidth
        var path = Path()

        path.move(to: CGPoint(x: startX, y: metrics.topY))
        path.addCurve(
            to: CGPoint(x: pointer.centerX, y: metrics.topY - configuration.pointerHeight),
            control1: CGPoint(x: pointer.centerX - 4, y: metrics.topY),
            control2: CGPoint(x: pointer.centerX - 3, y: metrics.topY - configuration.pointerHeight)
        )
        path.addCurve(
            to: CGPoint(x: endX, y: metrics.topY),
            control1: CGPoint(x: pointer.centerX + 3, y: metrics.topY - configuration.pointerHeight),
            control2: CGPoint(x: pointer.centerX + 4, y: metrics.topY)
        )

        return path
    }
}

private struct GeometryBadge: View {
    let title: String
    let value: CGFloat

    var body: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value, format: .number.precision(.fractionLength(0)))
                .font(.caption.monospacedDigit())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.thinMaterial, in: .rect(cornerRadius: 10))
    }
}

private struct GeometryGridView: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 24
            var path = Path()

            stride(from: .zero, through: size.width, by: step).forEach { positionX in
                path.move(to: CGPoint(x: positionX, y: .zero))
                path.addLine(to: CGPoint(x: positionX, y: size.height))
            }

            stride(from: .zero, through: size.height, by: step).forEach { positionY in
                path.move(to: CGPoint(x: .zero, y: positionY))
                path.addLine(to: CGPoint(x: size.width, y: positionY))
            }

            context.stroke(path, with: .color(.white.opacity(0.12)), lineWidth: 1)
        }
        .background(.black.opacity(0.12))
    }
}

// MARK: - Geometry Types

private struct PracticeBannerConfiguration: Equatable {
    static let totalHeight: CGFloat = 73
    static let bodyHeight: CGFloat = 64

    var pointerX: CGFloat
    var cornerRadius: CGFloat
    var pointerHalfWidth: CGFloat
    var pointerHeight: CGFloat
    var pointerBaseHandle: CGFloat
    var pointerPeakHandle: CGFloat
    var edgeRetractionDistance: CGFloat

    var animatableData: AnimatableData {
        get {
            AnimatablePair(
                pointerX,
                AnimatablePair(
                    cornerRadius,
                    AnimatablePair(
                        pointerHalfWidth,
                        AnimatablePair(
                            pointerHeight,
                            AnimatablePair(pointerBaseHandle, pointerPeakHandle)
                        )
                    )
                )
            )
        }
        set {
            pointerX = newValue.first
            cornerRadius = newValue.second.first
            pointerHalfWidth = newValue.second.second.first
            pointerHeight = newValue.second.second.second.first
            pointerBaseHandle = newValue.second.second.second.second.first
            pointerPeakHandle = newValue.second.second.second.second.second
        }
    }

    typealias AnimatableData = AnimatablePair<
        CGFloat,
        AnimatablePair<
            CGFloat,
            AnimatablePair<
                CGFloat,
                AnimatablePair<
                    CGFloat,
                    AnimatablePair<CGFloat, CGFloat>
                >
            >
        >
    >
}

private struct PracticeBannerMetrics {
    let rect: CGRect
    let configuration: PracticeBannerConfiguration
    let topY: CGFloat
    let cornerRadius: CGFloat

    init(
        rect: CGRect,
        configuration: PracticeBannerConfiguration
    ) {
        self.rect = rect
        self.configuration = configuration
        topY = rect.maxY - PracticeBannerConfiguration.bodyHeight
        cornerRadius = min(configuration.cornerRadius, PracticeBannerConfiguration.bodyHeight / 2)
    }
}

private struct Pointer {
    let centerX: CGFloat
    let halfWidth: CGFloat
    let height: CGFloat
    let retractProgress: CGFloat

    init(metrics: PracticeBannerMetrics) {
        let rect = metrics.rect
        let configuration = metrics.configuration
        let centerX = configuration.pointerX.clamped(to: rect.minX ... rect.maxX)
        let overflow = Swift.max(
            Swift.max(rect.minX - configuration.pointerX, configuration.pointerX - rect.maxX),
            .zero
        )
        let retractProgress = (1 - overflow / configuration.edgeRetractionDistance).clamped(to: .zero ... 1)
        let halfWidthProgress = sqrt(retractProgress)

        self.centerX = centerX
        self.retractProgress = retractProgress
        halfWidth = configuration.pointerHalfWidth * halfWidthProgress
        height = configuration.pointerHeight * retractProgress
    }
}

private struct PracticeBannerDiagnostics {
    let pointer: Pointer
    let start: BoundaryPoint
    let peak: CGPoint
    let end: BoundaryPoint
}

private struct BoundaryPoint {
    let point: CGPoint
    let tangent: CGVector
}

// MARK: - Helpers

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

private extension CGPoint {
    func offset(by vector: CGVector, distance: CGFloat) -> CGPoint {
        CGPoint(
            x: x + vector.dx * distance,
            y: y + vector.dy * distance
        )
    }
}

#Preview {
    ScrollView {
        PromotionBannerGeometryExperimentView()
            .padding(20)
    }
    .background(AppBackground())
}
