import SwiftUI

struct AnalysisScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Placeholder Analysis screen")
            NavigationLink("Aspects") {
                AspectsScreen()
            }
            NavigationLink("Midpoints") {
                MidpointsScreen()
            }
        }
    }
}
