//
//  CarPlaySceneDelegate.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import CarPlay
import SwiftUI

/// CarPlay Scene Delegate
/// Handles CarPlay lifecycle and presents the charging station interface
/// Uses shared ChargersViewModel for data consistency with iPhone app
class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    // MARK: - Properties
    
    var interfaceController: CPInterfaceController?
    
    /// Shared view model for charger data
    private let viewModel = ChargersViewModel()
    
    /// Root list template for nearby chargers
    private var nearbyChargersTemplate: CPListTemplate?
    
    // MARK: - CPTemplateApplicationSceneDelegate
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = interfaceController
        
        // Request location permission if needed
        viewModel.requestLocationIfNeeded()
        
        // Create and set root template
        let listTemplate = createNearbyChargersTemplate()
        self.nearbyChargersTemplate = listTemplate
        
        interfaceController.setRootTemplate(listTemplate, animated: true) { _, _ in
            // Fetch chargers after template is set
            Task { @MainActor in
                await self.viewModel.fetchNearbyChargers()
                self.updateChargersList()
            }
        }
    }
    
    @nonobjc func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = nil
        self.nearbyChargersTemplate = nil
    }
    
    // MARK: - Template Creation
    
    private func createNearbyChargersTemplate() -> CPListTemplate {
        // Loading state
        let loadingItem = CPListItem(
            text: "Loading nearby chargers...",
            detailText: "Searching for EV charging stations",
            image: UIImage(systemName: "bolt.car.fill")
        )
        loadingItem.isEnabled = false
        
        let section = CPListSection(items: [loadingItem])
        
        let template = CPListTemplate(
            title: "Nearby Chargers",
            sections: [section]
        )
        template.emptyViewTitleVariants = ["No Chargers Found"]
        template.emptyViewSubtitleVariants = ["Try moving to a different location"]
        
        return template
    }
    
    // MARK: - Update List
    
    @MainActor
    private func updateChargersList() {
        guard let template = nearbyChargersTemplate else { return }
        
        // Get stations (limited to 12 for CarPlay)
        let stations = Array(viewModel.stations.prefix(12))
        
        if stations.isEmpty {
            // Show empty state
            template.updateSections([])
            return
        }
        
        // Build list items
        let items: [CPListItem] = stations.map { station in
            createChargerListItem(for: station)
        }
        
        let section = CPListSection(items: items)
        template.updateSections([section])
    }
    
    private func createChargerListItem(for station: ChargingStation) -> CPListItem {
        // Build connector string
        let connectorText = station.connectorTypes
            .prefix(2)
            .map(\.displayName)
            .joined(separator: ", ")
        
        // Build distance string
        let distanceText: String
        if let location = viewModel.currentUserLocation {
            distanceText = station.formattedDistance(from: location)
        } else {
            distanceText = ""
        }
        
        let detailText = [connectorText, distanceText]
            .filter { !$0.isEmpty }
            .joined(separator: " • ")
        
        let item = CPListItem(
            text: station.name,
            detailText: detailText.isEmpty ? station.address : detailText,
            image: UIImage(systemName: "bolt.fill")
        )
        
        // Handle tap to show detail
        item.handler = { [weak self] _, completion in
            self?.showChargerDetail(for: station)
            completion()
        }
        
        return item
    }
    
    // MARK: - Charger Detail
    
    private func showChargerDetail(for station: ChargingStation) {
        guard let interfaceController else { return }
        
        // Build detail items
        var items: [CPInformationItem] = []
        
        // Address
        items.append(CPInformationItem(
            title: "Address",
            detail: station.address
        ))
        
        // Operator
        if let operatorName = station.operatorName {
            items.append(CPInformationItem(
                title: "Operator",
                detail: operatorName
            ))
        }
        
        // Connectors
        let connectorList = station.connectorTypes.map(\.displayName).joined(separator: "\n")
        items.append(CPInformationItem(
            title: "Connectors",
            detail: connectorList
        ))
        
        // Charging points
        items.append(CPInformationItem(
            title: "Charging Points",
            detail: "\(station.numberOfPoints)"
        ))
        
        // Cost
        if let cost = station.usageCost, !cost.isEmpty {
            items.append(CPInformationItem(
                title: "Cost",
                detail: cost
            ))
        }
        
        // Navigate button
        let navigateButton = CPTextButton(
            title: "Navigate",
            textStyle: .confirm
        ) { _ in
            NavigationService.navigateToStation(station)
        }
        
        let template = CPInformationTemplate(
            title: station.name,
            layout: .leading,
            items: items,
            actions: [navigateButton]
        )
        
        interfaceController.pushTemplate(template, animated: true, completion: nil)
    }
}

// MARK: - ChargersViewModel Extension for CarPlay

extension ChargersViewModel {
    /// Request location permission (call before fetching)
    func requestLocationIfNeeded() {
        // The locationService will handle this internally when we call fetchNearbyChargers
    }
}
