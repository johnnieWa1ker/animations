import SwiftUI

struct ControlSliderView<F: FormatStyle>: View where F.FormatInput == Double, F.FormatOutput == String {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: F

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.bold())

                Spacer()

                Text(value, format: format)
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Slider(value: $value, in: range)
        }
    }
}
