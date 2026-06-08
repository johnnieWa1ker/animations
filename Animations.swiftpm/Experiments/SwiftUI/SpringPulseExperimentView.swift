import SwiftUI

struct SpringPulseExperimentView: View {
    @State private var isAnimating = true
    @State private var scale = 1.24
    @State private var damping = 0.48
    @State private var speed = 0.9

    var body: some View {
        VStack(spacing: 18) {
            SpringPulsePreviewView(
                isAnimating: isAnimating,
                scale: scale,
                damping: damping,
                speed: speed
            )

            VStack(spacing: 16) {
                Toggle("Loop animation", isOn: $isAnimating)
                    .font(.headline)

                ControlSliderView(
                    title: "Scale",
                    value: $scale,
                    range: 1.05 ... 1.6,
                    format: .number.precision(.fractionLength(2))
                )

                ControlSliderView(
                    title: "Damping",
                    value: $damping,
                    range: 0.2 ... 0.9,
                    format: .number.precision(.fractionLength(2))
                )

                ControlSliderView(
                    title: "Speed",
                    value: $speed,
                    range: 0.35 ... 1.8,
                    format: .number.precision(.fractionLength(2))
                )
            }
            .padding(16)
            .background(.regularMaterial, in: .rect(cornerRadius: 16))
        }
    }
}

private struct SpringPulsePreviewView: View {
    let isAnimating: Bool
    let scale: Double
    let damping: Double
    let speed: Double

    @State private var isExpanded = false

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [.teal.opacity(0.28), .blue.opacity(0.08), .clear],
                center: .center,
                startRadius: 18,
                endRadius: 190
            )

            Circle()
                .fill(.teal.gradient)
                .frame(width: 116, height: 116)
                .scaleEffect(isExpanded ? scale : 1)
                .shadow(color: .teal.opacity(0.34), radius: isExpanded ? 34 : 14)
                .overlay {
                    Image(systemName: "sparkle")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }
                .animation(
                    isAnimating
                        ? .spring(response: speed, dampingFraction: damping).repeatForever(autoreverses: true)
                        : .spring(response: speed, dampingFraction: damping),
                    value: isExpanded
                )
        }
        .frame(height: 280)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: .rect(cornerRadius: 18))
        .onAppear {
            isExpanded = isAnimating
        }
        .onChange(of: isAnimating) { _, newValue in
            isExpanded = newValue
        }
        .onChange(of: scale) {
            restartIfNeeded()
        }
        .onChange(of: damping) {
            restartIfNeeded()
        }
        .onChange(of: speed) {
            restartIfNeeded()
        }
    }

    private func restartIfNeeded() {
        guard isAnimating else { return }
        isExpanded = false

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(80))
            isExpanded = true
        }
    }
}
