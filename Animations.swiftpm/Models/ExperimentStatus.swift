import SwiftUI

enum ExperimentStatus: String, Hashable {
    case ready = "Ready"
    case draft = "Draft"
    case planned = "Planned"

    var tint: Color {
        switch self {
        case .ready:
            .green
        case .draft:
            .orange
        case .planned:
            .secondary
        }
    }
}
