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
    @ObservedObject var appState: AppState // Observe the app state
    @State private var showAlert = false // State variable to control the alert
    @State private var alertMessage = "" // Message to show in the alert
    
    var body: some View {
        ZStack {
            Color(.systemBackground) // Background color for the entire view
                .edgesIgnoringSafeArea(.all) // Extend background to edges

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
                        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        // Basic validation: Check if the name is not empty and has valid characters
                        if !trimmedName.isEmpty, trimmedName.count >= 3 {
                            user.name = trimmedName
                            UserDefaults.standard.set(true, forKey: "isIntroCompleted")
                            appState.isIntroCompleted = true
                        } else {
                            // Show an alert
                            alertMessage = "Invalid username. Please enter a valid name with at least 3 characters."
                            showAlert = true
                        }
                    }) {
                        Text("Get Started")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(user.color)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Invalid Username"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Center the VStack
            .padding()
        }
    }
}
