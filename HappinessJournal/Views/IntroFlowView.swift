//
//  IntroFlowView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//

import SwiftUI

struct IntroFlowView: View {
    @ObservedObject private var viewModel = IntroPageViewModel()
    @ObservedObject var appState: AppState

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(viewModel.pages.indices, id: \.self) { index in
                IntroPageView(
                    pageData: viewModel.pages[index],
                    userName: Binding(
                        get: { viewModel.userName },
                        set: { viewModel.userName = $0 }
                    ),
                    isLastPage: index == viewModel.pages.count - 1,
                    appState: appState
                )
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .onChange(of: viewModel.userName) { oldValue, newValue in
            print("User name updated from \(oldValue) to \(newValue)")
        }
    }
}

#Preview {
    let appState = AppState()
    IntroFlowView(appState: appState)
}
