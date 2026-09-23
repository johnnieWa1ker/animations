import SwiftUI

struct IceExperimentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var settings = IceSettings()
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ice").font(.largeTitle.bold())
                    Text("The warmth of your touch").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "snowflake").font(.title).foregroundStyle(.cyan)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            if verticalSizeClass == .compact {
                HStack(spacing: 0) {
                    surface
                    ScrollView {
                        IceControls(settings: settings)
                            .padding(16)
                    }
                    .frame(width: 290)
                }
            } else {
                surface
                IceControls(settings: settings)
                    .padding(20)
            }
        }
        .background(Color(red: 0.035, green: 0.065, blue: 0.10))
        .preferredColorScheme(.dark)
        .tint(.cyan)
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
    }

    private var surface: some View {
        IceSurface(settings: settings, isRunning: isVisible && scenePhase == .active)
            .clipShape(.rect(cornerRadius: 28))
            .overlay {
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .bottom) {
                Label("Slide your finger across the glass", systemImage: "hand.draw")
                    .font(.footnote)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: .capsule)
                    .padding(18)
                    .allowsHitTesting(false)
            }
            .padding(.horizontal, 16)
            .accessibilityLabel("Frozen glass")
            .accessibilityHint("Drag to melt the ice. Use the Melt button to clear the entire surface.")
    }
}

@MainActor
@Observable
final class IceSettings {
    var thickness: Float = 0.75
    var refreezes = true
    var melts = false
    var resetID = 0

    func freeze() {
        melts = false
        resetID += 1
    }
}

private struct IceControls: View {
    @Bindable var settings: IceSettings

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Button("Freeze", systemImage: "arrow.clockwise", action: settings.freeze)
                    .buttonStyle(.borderedProminent)
                    .tint(.cyan.opacity(0.7))
                Button(settings.melts ? "Restore ice" : "Melt", systemImage: "drop") {
                    settings.melts.toggle()
                }
                .buttonStyle(.bordered)
            }
            HStack {
                Text("Thickness").font(.subheadline)
                Slider(value: $settings.thickness, in: 0.25...1)
                    .tint(.cyan)
                    .accessibilityLabel("Ice thickness")
            }
            Toggle("Refreeze automatically", isOn: $settings.refreezes)
                .font(.subheadline)
                .tint(.cyan)
        }
    }
}

/// Live SwiftUI content sampled directly by the ice layer effect.
struct IceBackdrop: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(colors: [Color(red: 0.015, green: 0.10, blue: 0.19),
                                        Color(red: 0.04, green: 0.32, blue: 0.40),
                                        Color(red: 0.40, green: 0.21, blue: 0.23)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                Circle()
                    .fill(Color(red: 1, green: 0.68, blue: 0.38).gradient)
                    .frame(width: geometry.size.width * 0.57)
                    .blur(radius: 1)
                    .offset(x: geometry.size.width * 0.22, y: -geometry.size.height * 0.12)
                ForEach(0..<5) { index in
                    MountainSilhouette(seed: CGFloat(index))
                        .fill(Color(red: 0.025 + Double(index) * 0.012,
                                    green: 0.12 + Double(index) * 0.016,
                                    blue: 0.17 + Double(index) * 0.021))
                        .offset(y: CGFloat(index) * geometry.size.height * 0.085)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("WINTER / 001").font(.caption.monospaced()).tracking(4)
                    Spacer()
                    Text("Stay\ncurious.")
                        .font(.system(size: min(geometry.size.width * 0.17, geometry.size.height * 0.14, 76), weight: .semibold, design: .serif))
                        .lineSpacing(-4)
                    if geometry.size.height > 300 {
                        Text("A little warmth changes everything.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer().frame(height: 62)
                    }
                }
                .padding(28)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.white)
            }
        }
    }
}

private struct MountainSilhouette: Shape {
    let seed: CGFloat

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: rect.height))
            for step in 0...40 {
                let x = CGFloat(step) / 40
                let wave = sin(x * 8 + seed * 2) * 0.08 + sin(x * 19 + seed) * 0.035
                path.addLine(to: CGPoint(x: x * rect.width, y: (0.50 + wave) * rect.height))
            }
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.closeSubpath()
        }
    }
}
