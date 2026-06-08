import SwiftUI

struct SectionPickerView: View {
    let sections: [ExperimentSection]
    @Binding var selectedSection: ExperimentSection

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(sections) { section in
                    Button {
                        withAnimation(.snappy(duration: 0.25)) {
                            selectedSection = section
                        }
                    } label: {
                        Label(section.title, systemImage: section.symbolName)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .foregroundStyle(selectedSection == section ? .white : section.tint)
                            .background {
                                Capsule()
                                    .fill(selectedSection == section ? section.tint : section.tint.opacity(0.12))
                            }
                    }
                    .accessibilityAddTraits(selectedSection == section ? .isSelected : [])
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }
}
