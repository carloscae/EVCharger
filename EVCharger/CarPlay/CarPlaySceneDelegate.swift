import CarPlay

/// CarPlay Scene Delegate
/// Handles CarPlay lifecycle and presents the charging station interface
class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    
    // MARK: - CPTemplateApplicationSceneDelegate
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = interfaceController
        
        // Create root template - nearby chargers list
        let listTemplate = createNearbyChargersTemplate()
        interfaceController.setRootTemplate(listTemplate, animated: true, completion: nil)
    }
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnectInterfaceController interfaceController: CPInterfaceController
    ) {
        self.interfaceController = nil
    }
    
    // MARK: - Template Creation
    
    private func createNearbyChargersTemplate() -> CPListTemplate {
        // Placeholder items - will be populated by ChargersViewModel
        let placeholderItem = CPListItem(
            text: "Loading nearby chargers...",
            detailText: "Searching for EV charging stations",
            image: UIImage(systemName: "bolt.car.fill")
        )
        
        let section = CPListSection(items: [placeholderItem])
        
        let template = CPListTemplate(
            title: "Nearby Chargers",
            sections: [section]
        )
        template.emptyViewTitleVariants = ["No Chargers Found"]
        template.emptyViewSubtitleVariants = ["Try moving to a different location"]
        
        return template
    }
}
