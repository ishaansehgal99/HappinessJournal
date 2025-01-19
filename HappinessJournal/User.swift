//
//  User.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//

import SwiftUI

class User: ObservableObject {
    static let sharedUser = User()

    @Published var name: String {
        didSet {
            UserDefaults.standard.set(name, forKey: "userName")
        }
    }

    @Published var color: Color {
        didSet {
            if let colorComponents = UIColor(color).cgColor.components {
                let rgbaComponents = Array(colorComponents.prefix(4)) // Ensure only R, G, B, A are saved
                UserDefaults.standard.set(rgbaComponents, forKey: "userColor")
            }
        }
    }

    @Published var streakDates: [Date] {
        didSet {
            let encodedStreaks = streakDates.map { $0.timeIntervalSince1970 }
            UserDefaults.standard.set(encodedStreaks, forKey: "userStreakDates")
        }
    }

    @Published var longestStreak: Int {
        didSet {
            UserDefaults.standard.set(longestStreak, forKey: "userLongestStreak")
        }
    }
    
    @Published var days: [String: Day] {
        didSet {
            let encodedDays = days.mapValues { $0.encode() }
            UserDefaults.standard.set(encodedDays, forKey: "userDays")
        }
    }
    
    @Published var startDate: Date {
        didSet {
            UserDefaults.standard.set(startDate.timeIntervalSince1970, forKey: "userStartDate")
        }
    }

    @Published var level: Int = 1 // Default to level 1
    @Published var xp: Int = 0 // Default to 0

    var goal: Int {
        didSet {
            UserDefaults.standard.set(goal, forKey: "userGoal")
        }
    }

    private init() {
        // Defer initialization of properties to avoid 'self' access before initialization.
        defer {
            // Set level and XP after initialization
            self.level = UserDefaults.standard.integer(forKey: "userLevel")
            if self.level == 0 { self.level = 1 } // Default to 1 if not set

            self.xp = UserDefaults.standard.integer(forKey: "userXP")

            // Save goal
            self.goal = UserDefaults.standard.integer(forKey: "userGoal")
        }

        // Initialize other properties
        self.name = UserDefaults.standard.string(forKey: "userName") ?? ""
        // Load Color
        self.color = User.loadColor()
        
        // Load streaks
        if let savedStreakDates = UserDefaults.standard.array(forKey: "userStreakDates") as? [Double] {
            self.streakDates = savedStreakDates.map { Date(timeIntervalSince1970: $0) }
        } else {
            self.streakDates = []
        }

        // Load longest streak
        self.longestStreak = UserDefaults.standard.integer(forKey: "userLongestStreak")
        
        // Load days
        self.days = User.loadDays()
        
        // Load start date
        if let savedStartDate = UserDefaults.standard.object(forKey: "userStartDate") as? Double {
            self.startDate = Date(timeIntervalSince1970: savedStartDate)
        } else {
            self.startDate = Date() // Default to today if not set
        }
        
        // Load Goal
        self.goal = UserDefaults.standard.integer(forKey: "userGoal") == 0 ? 3 : UserDefaults.standard.integer(forKey: "userGoal")
    }
    
    func save() {
        // Save all user-related data
        UserDefaults.standard.set(name, forKey: "userName")

        if let colorComponents = UIColor(color).cgColor.components {
            let rgbaComponents = Array(colorComponents.prefix(4)) // Ensure only R, G, B, A are saved
            UserDefaults.standard.set(rgbaComponents, forKey: "userColor")
        }

        let encodedStreaks = streakDates.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(encodedStreaks, forKey: "userStreakDates")

        UserDefaults.standard.set(longestStreak, forKey: "userLongestStreak")

        let encodedDays = days.mapValues { $0.encode() }
        UserDefaults.standard.set(encodedDays, forKey: "userDays")

        UserDefaults.standard.set(startDate.timeIntervalSince1970, forKey: "userStartDate")
        UserDefaults.standard.set(goal, forKey: "userGoal")
        UserDefaults.standard.set(level, forKey: "userLevel")
        UserDefaults.standard.set(xp, forKey: "userXP")
    }
    
    // Helper function to load color
    static func loadColor() -> Color {
        if let components = UserDefaults.standard.array(forKey: "userColor") as? [CGFloat] {
            if components.count >= 4 {
                return Color(
                    red: components[0],
                    green: components[1],
                    blue: components[2],
                    opacity: components[3]
                )
            } else if components.count >= 3 {
                return Color(
                    red: components[0],
                    green: components[1],
                    blue: components[2],
                    opacity: 1.0
                )
            }
        }
        return .blue // Default color
    }
    
    // Helper function to load days
    static func loadDays() -> [String: Day] {
        if let savedDays = UserDefaults.standard.dictionary(forKey: "userDays") as? [String: Data] {
            return savedDays.compactMapValues { Day.decode(from: $0) }
        }
        return [:]
    }
}
