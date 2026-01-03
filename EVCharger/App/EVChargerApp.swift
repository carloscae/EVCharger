import SwiftUI
import SwiftData

/// EVCharger App Entry Point
/// CarPlay-native EV charger finder with iOS companion app
@main
struct EVChargerApp: App {
    
    /// SwiftData model container for offline caching
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            // Models will be added here as they're implemented
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
