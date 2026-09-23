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
            id: "swiftui-shape-morph",
            section: .swiftUI,
            kind: .shapeMorph,
            title: "Shape Morph",
            subtitle: "Custom shape with animated size and control points.",
            symbolName: "rectangle.on.rectangle.angled",
            tint: .purple,
            status: .ready,
            tags: ["shape", "points", "morph"]
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
            id: "geometry-promotion-banner",
            section: .geometry,
            kind: .promotionBannerGeometry,
            title: "Promotion Banner Geometry",
            subtitle: "Practice drawing a single shape with arcs, Bezier handles and a moving pointer.",
            symbolName: "point.topleft.down.curvedto.point.bottomright.up",
            tint: .orange,
            status: .draft,
            tags: ["shape", "path", "arc", "bezier", "tooltip", "pointer"]
        ),
        AnimationExperiment(
            id: "geometry-programmable-shape",
            section: .geometry,
            kind: .programmableShapeGeometry,
            title: "Programmable Shape Host",
            subtitle: "A bare Swift Shape host for writing path(in:) directly in Xcode.",
            symbolName: "curlybraces.square",
            tint: .pink,
            status: .ready,
            tags: ["shape", "path", "code", "xcode", "bezier"]
        ),
        AnimationExperiment(
            id: "metal-shader-preview",
            section: .metal,
            kind: .helloMetal,
            title: "Hello Metal",
            subtitle: "First lesson about Metal: drawing primitives",
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
