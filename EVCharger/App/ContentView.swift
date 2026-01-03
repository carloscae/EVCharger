import SwiftUI
import MapKit

/// Root view for iPhone app
/// Shows map with nearby chargers and provides access to settings
struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Map placeholder - will be replaced with charger pins
                Map()
                    .ignoresSafeArea(edges: .top)
                
                // Bottom card overlay placeholder
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "bolt.car.fill")
                                .font(.title2)
                                .foregroundStyle(.green)
                            
                            Text("EVCharger")
                                .font(.title2.bold())
                            
                            Spacer()
                            
                            Button {
                                // Settings action
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Text("Find nearby EV charging stations")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
