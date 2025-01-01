//
//  MainAppView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//

import SwiftUI

struct MainAppView: View {
    @ObservedObject private var user = User.sharedUser

    var body: some View {
        VStack {
            Text("Welcome, \(user.name)!")
                .font(.title)
                .padding()

            Text("Your app's main content goes here.")
                .font(.subheadline)
        }
        .padding()
    }
}

#Preview {
    MainAppView()
}
