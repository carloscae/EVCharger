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
    
    /// Currently selected connector filter
    private var selectedConnectorFilter: ConnectorType?
    
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
    
    func templateApplicationScene(
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
        
        // Add filter button
        let filterButton = CPBarButton(title: "Filter") { [weak self] _ in
            self?.showConnectorFilter()
        }
        template.trailingNavigationBarButtons = [filterButton]
        
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
    
    // MARK: - Connector Filter
    
    private func showConnectorFilter() {
        guard let interfaceController else { return }
        
        // Build filter options
        var items: [CPListItem] = []
        
        // All option
        let allItem = CPListItem(
            text: "All Connectors",
            detailText: "Show all charger types",
            image: UIImage(systemName: "bolt.fill")
        )
        allItem.accessoryType = selectedConnectorFilter == nil ? .cloud : .none
        allItem.handler = { [weak self] _, completion in
            self?.applyConnectorFilter(nil)
            completion()
        }
        items.append(allItem)
        
        // Individual connector types
        for connector in ConnectorType.allCases {
            let item = CPListItem(
                text: connector.displayName,
                detailText: nil,
                image: UIImage(systemName: connector.sfSymbol)
            )
            item.accessoryType = selectedConnectorFilter == connector ? .cloud : .none
            item.handler = { [weak self] _, completion in
                self?.applyConnectorFilter(connector)
                completion()
            }
            items.append(item)
        }
        
        let section = CPListSection(items: items)
        let filterTemplate = CPListTemplate(
            title: "Filter by Connector",
            sections: [section]
        )
        
        interfaceController.pushTemplate(filterTemplate, animated: true, completion: nil)
    }
    
    private func applyConnectorFilter(_ connector: ConnectorType?) {
        selectedConnectorFilter = connector
        viewModel.selectedConnector = connector
        
        // Pop back to list
        interfaceController?.popTemplate(animated: true, completion: nil)
        
        // Update list
        Task { @MainActor in
            updateChargersList()
        }
    }
    
    // MARK: - Route Planning
    
    /// Currently active route
    private var activeRoute: PlannedRoute?
    private var currentStopIndex: Int = 0
    
    /// Show route status template for active route
    func showRouteStatus(route: PlannedRoute) {
        guard let interfaceController else { return }
        
        self.activeRoute = route
        self.currentStopIndex = 0
        
        let template = createRouteStatusTemplate(route: route)
        interfaceController.pushTemplate(template, animated: true, completion: nil)
    }
    
    private func createRouteStatusTemplate(route: PlannedRoute) -> CPInformationTemplate {
        var items: [CPInformationItem] = []
        
        // Destination
        items.append(CPInformationItem(
            title: "Destination",
            detail: route.destinationName
        ))
        
        // Distance
        items.append(CPInformationItem(
            title: "Distance",
            detail: "\(Int(route.totalDistanceKm)) km"
        ))
        
        // Total time
        let hours = route.totalTimeMinutes / 60
        let mins = route.totalTimeMinutes % 60
        let timeStr = hours > 0 ? "\(hours)h \(mins)m" : "\(mins) min"
        items.append(CPInformationItem(
            title: "Total Time",
            detail: timeStr
        ))
        
        // Charging stops
        items.append(CPInformationItem(
            title: "Charging Stops",
            detail: route.stops.isEmpty ? "None needed" : "\(route.stops.count) stops"
        ))
        
        var actions: [CPTextButton] = []
        
        // Navigate to next stop
        if let nextStop = route.stops.first {
            let navigateButton = CPTextButton(
                title: "Navigate to First Stop",
                textStyle: .confirm
            ) { [weak self] _ in
                NavigationService.navigateToStation(nextStop.station)
                self?.showNextStopTemplate(stop: nextStop, index: 0)
            }
            actions.append(navigateButton)
        } else {
            // No stops - navigate to destination
            let navigateButton = CPTextButton(
                title: "Start Navigation",
                textStyle: .confirm
            ) { _ in
                // Open Maps to destination
                let coordinate = route.destination
                let placemark = MKPlacemark(coordinate: coordinate)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = route.destinationName
                mapItem.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                ])
            }
            actions.append(navigateButton)
        }
        
        return CPInformationTemplate(
            title: "Route to \(route.destinationName)",
            layout: .leading,
            items: items,
            actions: actions
        )
    }
    
    private func showNextStopTemplate(stop: ChargingStop, index: Int) {
        guard let interfaceController else { return }
        
        var items: [CPInformationItem] = []
        
        items.append(CPInformationItem(
            title: "Stop \(index + 1)",
            detail: stop.station.name
        ))
        
        items.append(CPInformationItem(
            title: "Distance",
            detail: "\(Int(stop.distanceFromStartKm)) km from start"
        ))
        
        items.append(CPInformationItem(
            title: "Arrival Charge",
            detail: "\(stop.arrivalChargePercent)%"
        ))
        
        items.append(CPInformationItem(
            title: "Charging Time",
            detail: "~\(stop.chargingTimeMinutes) min to 80%"
        ))
        
        // Skip button
        let skipButton = CPTextButton(
            title: "Skip This Stop",
            textStyle: .normal
        ) { [weak self] _ in
            guard let self = self, let route = self.activeRoute else { return }
            self.currentStopIndex += 1
            if self.currentStopIndex < route.stops.count {
                let nextStop = route.stops[self.currentStopIndex]
                NavigationService.navigateToStation(nextStop.station)
            }
            interfaceController.popTemplate(animated: true, completion: nil)
        }
        
        // Navigate button
        let navigateButton = CPTextButton(
            title: "Navigate",
            textStyle: .confirm
        ) { _ in
            NavigationService.navigateToStation(stop.station)
        }
        
        let template = CPInformationTemplate(
            title: "Next Stop",
            layout: .leading,
            items: items,
            actions: [navigateButton, skipButton]
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
