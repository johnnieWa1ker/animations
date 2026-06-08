import SwiftUI

struct RoadmapView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Next slots", systemImage: "plus.app")
                .font(.headline)

            Text("Add a new case to the catalog, give it a kind, then route that kind inside the detail screen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: .rect(cornerRadius: 16))
    }
}
