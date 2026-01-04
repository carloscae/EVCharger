//
//  APIConfig.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import Foundation

/// API Configuration for external services
enum APIConfig {
    /// Open Charge Map API Key
    /// Register at: https://openchargemap.org/site/profile/applications
    /// 
    /// INSTRUCTIONS TO GET YOUR KEY:
    /// 1. Go to https://openchargemap.org/site/profile/signup
    /// 2. Create a free account
    /// 3. Go to https://openchargemap.org/site/profile/applications
    /// 4. Click "Register Application"
    /// 5. Copy the API key and paste it below
    ///
    /// Replace "YOUR_API_KEY_HERE" with your actual key
    static let openChargeMapAPIKey: String? = "83460545-8e3c-4255-9453-f190637649c7"
}
