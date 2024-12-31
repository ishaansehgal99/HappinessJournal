//
//  IntroPageViewModel.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/29/24.
//

import Foundation
import SwiftUI

class IntroPageViewModel: ObservableObject {
    @Published var currentPage = 0
    // Computed property for userName
    var userName: String {
        get {
            User.sharedUser.name // Read the name from the User singleton
        }
        set {
            User.sharedUser.name = newValue // Update the User singleton
        }
    }
    
    let pages = [
        IntroPageData(imageName: "IconBig.png", title: "Three Good Things", description: "In just 5 minutes a day, increase your happiness and rewire your brain to focus on the positive."),
        IntroPageData(imageName: "PencilBig.png", title: "Log Your Highlights", description: "Studies have shown that writing down three good things every day has lasting effects on one's happiness, positivity, and optimism."),
        IntroPageData(imageName: "Badge.png", title: "Engage and Improve", description: "Level up, gain experience points (XP), view previous entries, set a customizable notification, choose a profile picture, and more.")
    ]
    
    func saveUserName() {
        guard !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        User.sharedUser.name = userName
        let savedData = try? NSKeyedArchiver.archivedData(withRootObject: User.sharedUser, requiringSecureCoding: false)
        UserDefaults.standard.set(savedData, forKey: "user")
    }
}
