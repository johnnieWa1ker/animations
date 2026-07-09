import SwiftUI

struct ExperimentDetailView: View {
    let experiment: AnimationExperiment

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ExperimentDetailHeaderView(experiment: experiment)

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
                case .shaderPreview:
                    ShaderPreviewPlaceholderView()
                case .particleField:
                    PlaceholderExperimentView(
                        title: "Particle field",
                        symbolName: "atom",
                        tint: experiment.tint,
                        message: "Use this slot for emitter settings, field strength and render diagnostics."
                    )
                }
            }
            .padding(20)
            .frame(maxWidth: 820, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(AppBackground())
        .navigationTitle(experiment.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
