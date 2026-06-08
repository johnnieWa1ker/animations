import SwiftUI

struct PlaceholderExperimentView: View {
    let title: String
    let symbolName: String
    let tint: Color
    let message: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: symbolName)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(tint)

            Text(title)
                .font(.title3.bold())

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .padding(20)
        .background(.regularMaterial, in: .rect(cornerRadius: 18))
    }
}
