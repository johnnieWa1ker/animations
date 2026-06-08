import SwiftUI

extension AnimationExperiment {
    static let catalog: [AnimationExperiment] = [
        AnimationExperiment(
            id: "swiftui-spring-pulse",
            section: .swiftUI,
            kind: .springPulse,
            title: "Spring Pulse",
            subtitle: "A small control surface for scale, damping and repeat speed.",
            symbolName: "circle.hexagongrid.circle",
            tint: .teal,
            status: .ready,
            tags: ["spring", "scale", "controls"]
        ),
        AnimationExperiment(
            id: "swiftui-matched-geometry",
            section: .swiftUI,
            kind: .matchedGeometry,
            title: "Matched Geometry",
            subtitle: "Prepared slot for transitions between compact and expanded states.",
            symbolName: "rectangle.2.swap",
            tint: .mint,
            status: .planned,
            tags: ["transition", "layout", "hero"]
        ),
        AnimationExperiment(
            id: "metal-shader-preview",
            section: .metal,
            kind: .shaderPreview,
            title: "Shader Preview",
            subtitle: "A future home for Metal shader parameters and preview surfaces.",
            symbolName: "waveform.path.ecg.rectangle",
            tint: .indigo,
            status: .draft,
            tags: ["metal", "shader", "preview"]
        ),
        AnimationExperiment(
            id: "metal-particle-field",
            section: .metal,
            kind: .particleField,
            title: "Particle Field",
            subtitle: "Space reserved for GPU-driven particles and field controls.",
            symbolName: "atom",
            tint: .cyan,
            status: .planned,
            tags: ["particles", "gpu", "field"]
        )
    ]
}
