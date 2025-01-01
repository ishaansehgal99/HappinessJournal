//
//  IntroFlowView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//

import SwiftUI

struct IntroFlowView: View {
    @ObservedObject private var viewModel = IntroPageViewModel()
    @ObservedObject private var user = User.sharedUser // Observe the User singleton
    @ObservedObject var appState: AppState

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(viewModel.pages.indices, id: \.self) { index in
                IntroPageView(
                    pageData: viewModel.pages[index],
                    userName: Binding(
                        get: { user.name }, // Directly update the User singleton
                        set: { user.name = $0 }
                    ),
                    isLastPage: index == viewModel.pages.count - 1,
                    appState: appState
                )
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .onChange(of: user.name) { oldValue, newValue in
            print("User name updated from \(oldValue) to \(newValue)")
        }
    }
}

#Preview {
    let appState = AppState()
    IntroFlowView(appState: appState)
}
