//
//  ContentView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/29/24.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var isIntroCompleted: Bool = UserDefaults.standard.bool(forKey: "isIntroCompleted")
}

struct ContentView: View {
    @StateObject private var appState = AppState()
    @ObservedObject private var user = User.sharedUser

    var body: some View {
        Group {
            if appState.isIntroCompleted  {
                MainAppView()
            } else {
                IntroFlowView(appState: appState)
            }
        }
        .onAppear {
            // Ensure the user data is loaded
            print("Current user name: \(user.name)")
        }
    }
}

#Preview {
    ContentView()
}

