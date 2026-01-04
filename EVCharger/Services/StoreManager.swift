//
//  StoreManager.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import Foundation
import StoreKit

/// Manages in-app purchases using StoreKit 2.
/// Product: com.evcharger.fullapp ($3.99 with 7-day free trial)
@MainActor
@Observable
final class StoreManager {
    
    // MARK: - Types
    
    enum PurchaseState: Equatable {
        case unknown
        case notPurchased
        case inTrial(daysRemaining: Int)
        case purchased
        case expired
    }
    
    // MARK: - Properties
    
    /// Current purchase/trial state
    private(set) var purchaseState: PurchaseState = .unknown
    
    /// Available products
    private(set) var products: [Product] = []
    
    /// Loading indicator
    private(set) var isLoading: Bool = false
    
    /// Error message
    private(set) var errorMessage: String?
    
    /// Product identifier
    static let productId = "com.evcharger.fullapp"
    
    /// Trial duration in days
    static let trialDays = 7
    
    /// Transaction listener task
    nonisolated(unsafe) private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Computed Properties
    
    /// Whether user has full access (purchased or in active trial)
    var hasFullAccess: Bool {
        switch purchaseState {
        case .purchased, .inTrial:
            return true
        case .unknown, .notPurchased, .expired:
            return false
        }
    }
    
    /// Days remaining in trial (nil if not in trial)
    var trialDaysRemaining: Int? {
        if case .inTrial(let days) = purchaseState {
            return days
        }
        return nil
    }
    
    /// Price string for display
    var priceString: String {
        products.first?.displayPrice ?? "$3.99"
    }
    
    // MARK: - Initialization
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchaseState()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Load products from App Store
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            products = try await Product.products(for: [Self.productId])
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Purchase the full app
    func purchase() async -> Bool {
        guard let product = products.first else {
            errorMessage = "Product not available"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the transaction
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await updatePurchaseState()
                    isLoading = false
                    return true
                    
                case .unverified(_, let error):
                    errorMessage = "Transaction verification failed: \(error.localizedDescription)"
                    isLoading = false
                    return false
                }
                
            case .userCancelled:
                isLoading = false
                return false
                
            case .pending:
                errorMessage = "Purchase pending approval"
                isLoading = false
                return false
                
            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    /// Restore previous purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updatePurchaseState()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Start free trial
    func startTrial() {
        let trialStartDate = Date()
        UserDefaults.standard.set(trialStartDate, forKey: "trialStartDate")
        updateTrialState()
    }
    
    // MARK: - Private Methods
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await MainActor.run {
                        try self.checkVerified(result)
                    }
                    await self.updatePurchaseState()
                    await transaction.finish()
                } catch {
                    // Handle verification failure
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified(_, let error):
            throw error
        }
    }
    
    private func updatePurchaseState() async {
        // Check for existing purchase
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if transaction.productID == Self.productId {
                    // Check if revoked
                    if transaction.revocationDate != nil {
                        purchaseState = .expired
                    } else {
                        purchaseState = .purchased
                    }
                    return
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        // No purchase found, check trial
        updateTrialState()
    }
    
    private func updateTrialState() {
        guard let trialStartDate = UserDefaults.standard.object(forKey: "trialStartDate") as? Date else {
            purchaseState = .notPurchased
            return
        }
        
        let daysSinceTrialStart = Calendar.current.dateComponents([.day], from: trialStartDate, to: Date()).day ?? 0
        let daysRemaining = Self.trialDays - daysSinceTrialStart
        
        if daysRemaining > 0 {
            purchaseState = .inTrial(daysRemaining: daysRemaining)
        } else {
            purchaseState = .expired
        }
    }
}
