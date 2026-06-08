import SwiftUI

struct ExperimentDetailHeaderView: View {
    let experiment: AnimationExperiment

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: experiment.symbolName)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(experiment.tint.gradient, in: .rect(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 5) {
                    Text(experiment.section.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(experiment.tint)

                    Text(experiment.title)
                        .font(.title.bold())
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text(experiment.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
