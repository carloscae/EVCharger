//
//  EVChargerShortcuts.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import AppIntents

/// App Shortcuts provider - exposes Siri phrases to the system
struct EVChargerShortcuts: AppShortcutsProvider {
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FindChargerIntent(),
            phrases: [
                "Find a charger with \(.applicationName)",
                "Find charger in \(.applicationName)",
                "Show chargers in \(.applicationName)"
            ],
            shortTitle: "Find Charger",
            systemImageName: "bolt.car"
        )
        
        AppShortcut(
            intent: NavigateToChargerIntent(),
            phrases: [
                "Navigate to charger with \(.applicationName)",
                "Go to charger with \(.applicationName)",
                "Charger directions with \(.applicationName)"
            ],
            shortTitle: "Navigate to Charger",
            systemImageName: "car.fill"
        )
    }
}
