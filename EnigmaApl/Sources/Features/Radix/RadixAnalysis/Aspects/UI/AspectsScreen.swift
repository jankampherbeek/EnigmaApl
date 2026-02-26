import SwiftUI

struct AspectsScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Placeholder for AspectsScreen")
            Button("Close") {
                dismiss()
            }
        }
    }
}
