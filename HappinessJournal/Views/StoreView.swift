//  StoreView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//

import SwiftUI

struct StoreView: View {
    @ObservedObject private var user = User.sharedUser
    @State private var selectedColor: Color = User.sharedUser.color
    @State private var isColorChanged: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("Store")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(user.color)
                        .padding()
                    
                    // XP Multiplier Section
                    StoreItemView(
                        title: "XP Multiplier",
                        description: "Double your XP earnings to level up faster!",
                        buttonTitle: user.boughtMulti ? "Purchased" : "$0.99",
                        isPurchased: user.boughtMulti,
                        onTap: {
                            if !user.boughtMulti {
                                purchaseXPMultiplier()
                            }
                        }
                    )

                    // Restore Purchases Button
                    Button("Restore Purchases") {
                        restorePurchases()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(user.color)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
    }

    // MARK: - Helper Functions

    private func purchaseXPMultiplier() {
        // Simulate an XP multiplier purchase
        user.boughtMulti = true
        user.xpMultiplier = 2
    }

    private func restorePurchases() {
        // Simulate restoring purchases
        user.boughtMulti = false
        user.xpMultiplier = 1
    }
}

struct StoreItemView<Content: View>: View {
    let title: String
    let description: String
    let buttonTitle: String
    let isPurchased: Bool
    let onTap: () -> Void
    let additionalContent: (() -> Content)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)

            Button(action: onTap) {
                Text(buttonTitle)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isPurchased ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isPurchased)

            if let additionalContent = additionalContent {
                additionalContent()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

extension StoreItemView where Content == EmptyView {
    init(
        title: String,
        description: String,
        buttonTitle: String,
        isPurchased: Bool,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.isPurchased = isPurchased
        self.onTap = onTap
        self.additionalContent = nil
    }
}

#Preview {
    StoreView()
}
