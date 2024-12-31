//
//  IntroPageView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/29/24.
//

import SwiftUI

struct IntroPageView: View {
    let pageData: IntroPageData
    @Binding var userName: String
    let isLastPage: Bool
    @ObservedObject private var user = User.sharedUser // Observe the User singleton

    
    var body: some View {
        VStack(spacing: 20) {
            Image(pageData.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: isLastPage ? 125 : 150, height: isLastPage ? 125 : 150)
                .foregroundColor(user.color)
            
            Text(pageData.title)
                .font(.system(size: 25, weight: .medium))
                .foregroundColor(user.color)
                .multilineTextAlignment(.center)
            
            Text(pageData.description)
                .font(.system(size: 19, weight: .thin))
                .foregroundColor(user.color)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            if isLastPage {
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundColor(user.color)
                    .onSubmit {
                        if !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            user.name = userName
                        }
                    }
                
                Button(action: {
                    user.name = userName
                }) {
                    Text("Get Started")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(user.color)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
        }
        .padding()
    }
}
