//
//  TrialBannerView.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import SwiftUI

/// Banner view showing trial status and purchase option.
struct TrialBannerView: View {
    @Environment(StoreManager.self) private var storeManager
    
    @State private var isShowingPurchase = false
    
    var body: some View {
        switch storeManager.purchaseState {
        case .inTrial(let daysRemaining):
            trialBanner(daysRemaining: daysRemaining)
        case .expired:
            expiredBanner
        case .notPurchased:
            startTrialBanner
        case .purchased, .unknown:
            EmptyView()
        }
    }
    
    // MARK: - Banner Views
    
    private func trialBanner(daysRemaining: Int) -> some View {
        HStack {
            Image(systemName: "clock.fill")
                .foregroundStyle(.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Free Trial Active")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(daysRemaining) day\(daysRemaining == 1 ? "" : "s") remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button("Unlock") {
                isShowingPurchase = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .sheet(isPresented: $isShowingPurchase) {
            PurchaseSheet()
        }
    }
    
    private var expiredBanner: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Trial Expired")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Unlock full access")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button("Unlock \(storeManager.priceString)") {
                isShowingPurchase = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
        .background(.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .sheet(isPresented: $isShowingPurchase) {
            PurchaseSheet()
        }
    }
    
    private var startTrialBanner: some View {
        HStack {
            Image(systemName: "gift.fill")
                .foregroundStyle(.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Start 7-Day Free Trial")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Full access, no credit card required")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button("Start Trial") {
                storeManager.startTrial()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
        .background(.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Purchase Sheet

struct PurchaseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreManager.self) private var storeManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "bolt.car.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                    .padding(.top, 40)
                
                // Title
                Text("Unlock EVCharger")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Features
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "map.fill", text: "Find nearby chargers")
                    FeatureRow(icon: "car.fill", text: "Full CarPlay integration")
                    FeatureRow(icon: "arrow.down.doc.fill", text: "Offline access")
                    FeatureRow(icon: "line.3.horizontal.decrease.circle.fill", text: "Connector filtering")
                    FeatureRow(icon: "location.fill", text: "One-tap navigation")
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Price
                Text("One-time purchase")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(storeManager.priceString)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Purchase button
                Button {
                    Task {
                        let success = await storeManager.purchase()
                        if success {
                            dismiss()
                        }
                    }
                } label: {
                    if storeManager.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Purchase")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.green)
                .padding(.horizontal, 32)
                .disabled(storeManager.isLoading)
                
                // Restore button
                Button("Restore Purchases") {
                    Task {
                        await storeManager.restorePurchases()
                    }
                }
                .font(.footnote)
                .padding(.bottom, 32)
                
                // Error message
                if let error = storeManager.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .frame(width: 24)
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    TrialBannerView()
        .environment(StoreManager())
}
