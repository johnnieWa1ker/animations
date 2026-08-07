import SwiftUI

struct ProgrammableShapeGeometryExperimentView: View {

    @State private var pointerPosition: CGFloat = 0.6

    var body: some View {
        VStack(spacing: 18) {
            GeometryLabShapeHost(
                shape: GeometryLabScratchShape(
                    pointerHeight: 20,
                    cornerRadius: 50,
                    pointerPosition: pointerPosition
                ),
                fill: .pink.opacity(0.26),
                stroke: .pink,
                lineWidth: 3
            ) {
                GeometryLabScratchDiagnosticsOverlay(
                    pointerHeight: 20,
                    cornerRadius: 50,
                    pointerPosition: pointerPosition
                )
            }

            Button("Move pointer") {
                withAnimation(.snappy(duration: 0.5)) {
                    pointerPosition = pointerPosition == 0.6 ? 0.05 : 0.6
                }
            }
        }
    }
}

// MARK: - Scratch Shape

struct GeometryLabScratchShape: Shape {

    let pointerHeight: CGFloat
    let cornerRadius: CGFloat
    var pointerPosition: CGFloat

    var animatableData: CGFloat {
        get { pointerPosition }
        set { pointerPosition = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let layout = BubbleShapeLayout(
            rect: rect,
            pointerHeight: pointerHeight,
            cornerRadius: cornerRadius,
            pointerPosition: pointerPosition
        )

        var path = Path()
        path.move(to: layout.startPoint)
        path.addLine(to: layout.topRightEntry)
        path.addQuadCurve(to: layout.topRightExit, control: layout.topRightControl)
        path.addLine(to: layout.bottomRightEntry)
        path.addQuadCurve(to: layout.bottomRightExit, control: layout.bottomRightControl)

        // Pointer. Start

        path.addLine(to: layout.pointerRightBaseEntry)
        path.addQuadCurve(to: layout.pointerRightBaseExit, control: layout.pointerRightBase)

        path.addLine(to: layout.pointerTipRightEntry)
        path.addQuadCurve(to: layout.pointerTipLeftExit, control: layout.pointerTip)
        path.addLine(to: layout.pointerLeftBaseEntry)

        path.addQuadCurve(to: layout.pointerLeftBaseExit, control: layout.pointerLeftBase)

        // Pointer. End

        path.addLine(to: layout.bottomLeftEntry)
        path.addQuadCurve(to: layout.bottomLeftExit, control: layout.bottomLeftControl)
        path.addLine(to: layout.topLeftEntry)
        path.addQuadCurve(to: layout.startPoint, control: layout.topLeftControl)
        path.closeSubpath()
        return path
    }
}

// MARK: - GeometryLabScratchDiagnosticsOverlay

struct GeometryLabScratchDiagnosticsOverlay: View {
    let pointerHeight: CGFloat
    let cornerRadius: CGFloat
    let pointerPosition: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let layout = BubbleShapeLayout(
                rect: CGRect(origin: .zero, size: proxy.size),
                pointerHeight: pointerHeight,
                cornerRadius: cornerRadius,
                pointerPosition: pointerPosition
            )

            ZStack {
                Path { path in
                    for line in layout.diagnosticLines {
                        path.move(to: line.start)
                        path.addLine(to: line.end)
                    }
                }
                .stroke(
                    .blue,
                    style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                )

                ForEach(layout.diagnosticPoints) { point in
                    Circle()
                        .fill(point.kind.color)
                        .frame(width: 7, height: 7)
                        .position(point.position)
                }
            }
        }
    }
}

struct DiagnosticPoint: Identifiable {
    let id: String
    let position: CGPoint
    let kind: Kind

    enum Kind {
        case anchor
        case control
        case pointer
        
        var color: Color {
            switch self {
            case .anchor: return .blue
            case .control: return .orange
            case .pointer: return .green
            }
        }
    }
}

struct DiagnosticLine: Identifiable {
    let id: String
    let start: CGPoint
    let end: CGPoint
}

private struct BubbleShapeLayout {
    let rect: CGRect
    let pointerHalfWidth: CGFloat

    let contentBottomY: CGFloat
    let pointerPositionX: CGFloat
    let safePointerMinX: CGFloat
    let safePointerMaxX: CGFloat

    let clampedCornerRadius: CGFloat
    let clampedPointerCornerRadius: CGFloat

    let startPoint: CGPoint
    let topRightEntry: CGPoint
    let topRightExit: CGPoint
    let topRightControl: CGPoint
    let bottomRightEntry: CGPoint
    let bottomRightExit: CGPoint
    let bottomRightControl: CGPoint
    let bottomLeftEntry: CGPoint
    let bottomLeftExit: CGPoint
    let bottomLeftControl: CGPoint
    let topLeftEntry: CGPoint
    let topLeftControl: CGPoint

    let pointerTip: CGPoint
    let pointerLeftBase: CGPoint
    let pointerRightBase: CGPoint
    let pointerRightBaseEntry: CGPoint
    let pointerRightBaseExit: CGPoint
    let pointerTipRightEntry: CGPoint
    let pointerTipLeftExit: CGPoint
    let pointerLeftBaseEntry: CGPoint
    let pointerLeftBaseExit: CGPoint

    var diagnosticPoints: [DiagnosticPoint] {
        [
            .init(id: "topLeftEntry", position: topLeftEntry, kind: .anchor),
            .init(id: "topLeftControl", position: topLeftControl, kind: .control),
            .init(id: "startPoint", position: startPoint, kind: .anchor),

            .init(id: "topRightEntry", position: topRightEntry, kind: .anchor),
            .init(id: "topRightControl", position: topRightControl, kind: .control),
            .init(id: "topRightExit", position: topRightExit, kind: .anchor),
            
            .init(id: "bottomRightEntry", position: bottomRightEntry, kind: .anchor),
            .init(id: "bottomRightControl", position: bottomRightControl, kind: .control),
            .init(id: "bottomRightExit", position: bottomRightExit, kind: .anchor),
            
            .init(id: "bottomLeftEntry", position: bottomLeftEntry, kind: .anchor),
            .init(id: "bottomLeftControl", position: bottomLeftControl, kind: .control),
            .init(id: "bottomLeftExit", position: bottomLeftExit, kind: .anchor),
            
            .init(id: "pointerTip", position: pointerTip, kind: .pointer),
            .init(id: "pointerLeftBase", position: pointerLeftBase, kind: .pointer),
            .init(id: "pointerRightBase", position: pointerRightBase, kind: .pointer)
        ]
    }

    var diagnosticLines: [DiagnosticLine] {
        [
            DiagnosticLine(
                id: "topLeftEntryToControl",
                start: topLeftEntry,
                end: topLeftControl
            ),
            DiagnosticLine(
                id: "topLeftControlToExit",
                start: topLeftControl,
                end: startPoint
            ),
            DiagnosticLine(
                id: "topRightEntryToControl",
                start: topRightEntry,
                end: topRightControl
            ),
            DiagnosticLine(
                id: "topRightControlToExit",
                start: topRightControl,
                end: topRightExit
            ),
            DiagnosticLine(
                id: "bottomRightEntryToControl",
                start: bottomRightEntry,
                end: bottomRightControl
            ),
            DiagnosticLine(
                id: "bottomRightControlToExit",
                start: bottomRightControl,
                end: bottomRightExit
            ),
            DiagnosticLine(
                id: "bottomLeftEntryToControl",
                start: bottomLeftEntry,
                end: bottomLeftControl
            ),
            DiagnosticLine(
                id: "bottomLeftControlToExit",
                start: bottomLeftControl,
                end: bottomLeftExit
            )
        ]
    }

    init(
        rect: CGRect,
        pointerHeight: CGFloat,
        cornerRadius: CGFloat,
        pointerPosition: CGFloat
    ) {
        let clampedPointerHeight = min(pointerHeight, rect.height)
        let contentHeight = rect.height - clampedPointerHeight
        let contentBottomY = rect.minY + contentHeight
        let clampedCornerRadius = min(cornerRadius, rect.width / 2, contentHeight / 2)
        let pointerHalfWidth: CGFloat = 15
        let pointerCornerRadius: CGFloat = 8
        let clampedPointerCornerRadius = min(
            pointerCornerRadius,
            pointerHalfWidth * 0.25,
            clampedPointerHeight * 0.25
        )
        let rawPointerPositionX = rect.minX + rect.width * pointerPosition
        let safePointerMinX = rect.minX + clampedCornerRadius + pointerHalfWidth + clampedPointerCornerRadius
        let safePointerMaxX = rect.maxX - clampedCornerRadius - pointerHalfWidth - clampedPointerCornerRadius

        let pointerPositionX = min(
            max(rawPointerPositionX, safePointerMinX),
            safePointerMaxX
        )

        self.rect = rect
        self.pointerHalfWidth = pointerHalfWidth
        self.contentBottomY = contentBottomY
        self.pointerPositionX = pointerPositionX
        self.safePointerMinX = safePointerMinX
        self.safePointerMaxX = safePointerMaxX
        self.clampedCornerRadius = clampedCornerRadius
        self.clampedPointerCornerRadius = clampedPointerCornerRadius

        startPoint = CGPoint(x: rect.minX + clampedCornerRadius, y: rect.minY)
        topRightEntry = CGPoint(x: rect.maxX - clampedCornerRadius, y: rect.minY)
        topRightExit = CGPoint(x: rect.maxX, y: rect.minY + clampedCornerRadius)
        topRightControl = CGPoint(x: rect.maxX, y: rect.minY)
        bottomRightEntry = CGPoint(x: rect.maxX, y: contentBottomY - clampedCornerRadius)
        bottomRightExit = CGPoint(x: rect.maxX - clampedCornerRadius, y: contentBottomY)
        bottomRightControl = CGPoint(x: rect.maxX, y: contentBottomY)
        bottomLeftEntry = CGPoint(x: rect.minX + clampedCornerRadius, y: contentBottomY)
        bottomLeftExit = CGPoint(x: rect.minX, y: contentBottomY - clampedCornerRadius)
        bottomLeftControl = CGPoint(x: rect.minX, y: contentBottomY)
        topLeftEntry = CGPoint(x: rect.minX, y: rect.minY + clampedCornerRadius)
        topLeftControl = CGPoint(x: rect.minX, y: rect.minY)

        pointerTip = CGPoint(x: pointerPositionX, y: rect.maxY)
        pointerLeftBase = CGPoint(x: pointerPositionX - pointerHalfWidth, y: contentBottomY)
        pointerRightBase = CGPoint(x: pointerPositionX + pointerHalfWidth, y: contentBottomY)
        pointerRightBaseEntry = CGPoint(
            x: pointerPositionX + pointerHalfWidth + clampedPointerCornerRadius,
            y: contentBottomY
        )
        pointerRightBaseExit = CGPoint(
            x: pointerPositionX + pointerHalfWidth - clampedPointerCornerRadius,
            y: contentBottomY + clampedPointerCornerRadius
        )
        pointerTipRightEntry = CGPoint(
            x: pointerPositionX + clampedPointerCornerRadius,
            y: rect.maxY - clampedPointerCornerRadius
        )
        pointerTipLeftExit = CGPoint(
            x: pointerPositionX - clampedPointerCornerRadius,
            y: rect.maxY - clampedPointerCornerRadius
        )
        pointerLeftBaseEntry = CGPoint(
            x: pointerPositionX - pointerHalfWidth + clampedPointerCornerRadius,
            y: contentBottomY + clampedPointerCornerRadius
        )
        pointerLeftBaseExit = CGPoint(
            x: pointerPositionX - pointerHalfWidth - clampedPointerCornerRadius,
            y: contentBottomY
        )
    }
}

// MARK: - Host

private struct GeometryLabShapeHost<ScratchShape: Shape, DiagnosticsOverlay: View>: View {
    let shape: ScratchShape
    let fill: Color
    let stroke: Color
    let lineWidth: CGFloat
    let diagnosticsOverlay: DiagnosticsOverlay

    init(
        shape: ScratchShape,
        fill: Color,
        stroke: Color,
        lineWidth: CGFloat,
        @ViewBuilder diagnosticsOverlay: () -> DiagnosticsOverlay
    ) {
        self.shape = shape
        self.fill = fill
        self.stroke = stroke
        self.lineWidth = lineWidth
        self.diagnosticsOverlay = diagnosticsOverlay()
    }

    var body: some View {
        GeometryReader { proxy in
            let canvasSize = CGSize(
                width: min(proxy.size.width - 40, 460),
                height: 320
            )

            ZStack {
                GeometryLabCanvasGrid()

                shape
                    .fill(fill)
                    .overlay {
                        shape.stroke(
                            stroke,
                            style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round)
                        )
                    }
                    .frame(width: canvasSize.width, height: canvasSize.height)

                diagnosticsOverlay
                    .frame(width: canvasSize.width, height: canvasSize.height)
                    .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 380)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: .rect(cornerRadius: 18))
    }
}

private struct GeometryLabCanvasGrid: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 24
            var gridPath = Path()
            var axisPath = Path()

            for x in stride(from: .zero, through: size.width, by: step) {
                gridPath.move(to: CGPoint(x: x, y: .zero))
                gridPath.addLine(to: CGPoint(x: x, y: size.height))
            }

            for y in stride(from: .zero, through: size.height, by: step) {
                gridPath.move(to: CGPoint(x: .zero, y: y))
                gridPath.addLine(to: CGPoint(x: size.width, y: y))
            }

            axisPath.move(to: CGPoint(x: size.width / 2, y: .zero))
            axisPath.addLine(to: CGPoint(x: size.width / 2, y: size.height))
            axisPath.move(to: CGPoint(x: .zero, y: size.height / 2))
            axisPath.addLine(to: CGPoint(x: size.width, y: size.height / 2))

            context.stroke(gridPath, with: .color(.white.opacity(0.1)), lineWidth: 1)
            context.stroke(axisPath, with: .color(.white.opacity(0.22)), lineWidth: 1)
        }
        .background(.black.opacity(0.14))
    }
}

#Preview {
    ScrollView {
        ProgrammableShapeGeometryExperimentView()
            .padding(20)
    }
    .background(AppBackground())
}
