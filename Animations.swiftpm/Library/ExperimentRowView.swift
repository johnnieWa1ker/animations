import SwiftUI

struct ExperimentRowView: View {
    let experiment: AnimationExperiment

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: experiment.symbolName)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(experiment.tint.gradient, in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(experiment.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    StatusBadgeView(status: experiment.status)
                }

                Text(experiment.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 12)

            Image(systemName: "chevron.right")
                .font(.footnote.bold())
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary, lineWidth: 1)
        }
    }
}
