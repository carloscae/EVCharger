import SwiftUI
import MapKit

/// Root view for iPhone app
/// Shows map with nearby chargers and provides access to settings
struct ContentView: View {
    
    @State private var viewModel = ChargersViewModel()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ChargerMapView(viewModel: viewModel)
            .onAppear {
                viewModel.configure(modelContext: modelContext)
            }
    }
}

#Preview {
    ContentView()
}
