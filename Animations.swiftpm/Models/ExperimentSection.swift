import SwiftUI

enum ExperimentSection: String, CaseIterable, Identifiable, Hashable {
    case swiftUI
    case metal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .swiftUI:
            "SwiftUI Animations"
        case .metal:
            "Metal Shaders"
        }
    }

    var subtitle: String {
        switch self {
        case .swiftUI:
            "Implicit, explicit, gesture-driven, timeline and phase animations."
        case .metal:
            "Shader experiments, distortions, transitions and visual effects."
        }
    }

    var symbolName: String {
        switch self {
        case .swiftUI:
            "sparkles"
        case .metal:
            "cpu"
        }
    }

    var tint: Color {
        switch self {
        case .swiftUI:
            .teal
        case .metal:
            .indigo
        }
    }
}
