import SwiftUI

struct StatusBadgeView: View {
    let status: ExperimentStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption2.bold())
            .foregroundStyle(status.tint)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(status.tint.opacity(0.12), in: .capsule)
            .lineLimit(1)
    }
}
