import SwiftUI

struct ContentView: View {
    @State private var selectedSection: ExperimentSection = .swiftUI
    @State private var searchText = ""

    private var visibleExperiments: [AnimationExperiment] {
        AnimationExperiment.catalog.filter { experiment in
            experiment.section == selectedSection &&
                (searchText.isEmpty || experiment.matches(searchText))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    LibraryHeaderView()

                    SectionPickerView(
                        sections: ExperimentSection.allCases,
                        selectedSection: $selectedSection
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        SectionTitleView(
                            title: selectedSection.title,
                            subtitle: selectedSection.subtitle
                        )

                        LazyVStack(spacing: 12) {
                            ForEach(visibleExperiments) { experiment in
                                NavigationLink(value: experiment) {
                                    ExperimentRowView(experiment: experiment)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    RoadmapView()
                }
                .padding(20)
                .frame(maxWidth: 920, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .background(AppBackground())
            .searchable(text: $searchText, prompt: "Find experiments")
            .navigationDestination(for: AnimationExperiment.self) { experiment in
                ExperimentDetailView(experiment: experiment)
            }
        }
    }
}

#Preview {
    ContentView()
}
