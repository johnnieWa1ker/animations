import SwiftUI

enum ExperimentSection: String, CaseIterable, Identifiable, Hashable {
    case swiftUI
    case geometry
    case metal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .swiftUI:
            "SwiftUI Animations"
        case .geometry:
            "Geometry Lab"
        case .metal:
            "Metal Shaders"
        }
    }

    var subtitle: String {
        switch self {
        case .swiftUI:
            "Implicit, explicit, gesture-driven, timeline and phase animations."
        case .geometry:
            "Paths, Bezier curves, arcs, tangents and custom shape construction."
        case .metal:
            "Shader experiments, distortions, transitions and visual effects."
        }
    }

    var symbolName: String {
        switch self {
        case .swiftUI:
            "sparkles"
        case .geometry:
            "point.topleft.down.curvedto.point.bottomright.up"
        case .metal:
            "cpu"
        }
    }

    var tint: Color {
        switch self {
        case .swiftUI:
            .teal
        case .geometry:
            .orange
        case .metal:
            .indigo
        }
    }
}
