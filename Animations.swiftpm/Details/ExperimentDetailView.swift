import SwiftUI

struct ExperimentDetailView: View {
    let experiment: AnimationExperiment

    var body: some View {
        Group {
            if experiment.kind == .ice {
                // Keep touch-driven drawing outside the library's scrolling detail layout.
                experimentContent
            } else {
                standardDetail
            }
        }
        .navigationTitle(experiment.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var standardDetail: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ExperimentDetailHeaderView(experiment: experiment)

                experimentContent
            }
            .padding(20)
            .frame(maxWidth: 820, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(AppBackground())
    }

    @ViewBuilder
    private var experimentContent: some View {
        switch experiment.kind {
        case .springPulse:
            SpringPulseExperimentView()
        case .shapeMorph:
            ShapeMorphExperimentView()
        case .matchedGeometry:
            PlaceholderExperimentView(
                title: "Transition workbench",
                symbolName: "rectangle.2.swap",
                tint: experiment.tint,
                message: "This screen is ready for matched geometry controls and state previews."
            )
        case .promotionBannerGeometry:
            PromotionBannerGeometryExperimentView()
        case .programmableShapeGeometry:
            ProgrammableShapeGeometryExperimentView()
        case .helloMetal:
            MetalBasicExperimentView()
        case .ice:
            IceExperimentView()
        case .particleField:
            PlaceholderExperimentView(
                title: "Particle field",
                symbolName: "atom",
                tint: experiment.tint,
                message: "Use this slot for emitter settings, field strength and render diagnostics."
            )
        }
    }
}
