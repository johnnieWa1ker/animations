import SwiftUI

struct AnimationExperiment: Identifiable, Hashable {
    let id: String
    let section: ExperimentSection
    let kind: ExperimentKind
    let title: String
    let subtitle: String
    let symbolName: String
    let tint: Color
    let status: ExperimentStatus
    let tags: [String]

    func matches(_ query: String) -> Bool {
        let searchableText = ([title, subtitle] + tags).joined(separator: " ")
        return searchableText.localizedStandardContains(query)
    }
}
