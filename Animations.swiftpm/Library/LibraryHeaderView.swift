import SwiftUI

struct LibraryHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Animation lab", systemImage: "wand.and.stars")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)

            Text("Explore motion ideas without rebuilding the playground every time.")
                .font(.system(.largeTitle, design: .rounded).bold())
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Each experiment opens as its own screen with room for previews, sliders, toggles and notes.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 12)
    }
}
