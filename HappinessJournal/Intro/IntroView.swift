//
//  IntroView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/29/24.
//

import SwiftUI

struct IntroView: View {
    @StateObject private var viewModel = IntroPageViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(viewModel.pages.indices, id: \.self) { index in
                IntroPageView(pageData: viewModel.pages[index], userName: $viewModel.userName, isLastPage: index == viewModel.pages.count - 1)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .background(Color.white)
    }
}
