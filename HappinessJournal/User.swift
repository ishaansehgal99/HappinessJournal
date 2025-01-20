//
//  User.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//

import SwiftUI

class User: ObservableObject {
    static let sharedUser = User()

    // MARK: - Published Properties
    @Published var name: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @Published var hasReminder: Bool = UserDefaults.standard.bool(forKey: "hasReminder")
    @Published var reminderTime: String = UserDefaults.standard.string(forKey: "userReminderTime") ?? "9:00 AM"
    @Published var color: Color = User.loadColor()
    @Published var boughtMulti: Bool = UserDefaults.standard.bool(forKey: "userBoughtMulti")
    @Published var xpMultiplier: Int = UserDefaults.standard.integer(forKey: "userXPMultiplier") == 0 ? 1 : UserDefaults.standard.integer(forKey: "userXPMultiplier")
    @Published var streakDates: [Date] = User.loadStreakDates()
    @Published var longestStreak: Int = UserDefaults.standard.integer(forKey: "userLongestStreak")
    @Published var days: [String: Day] = User.loadDays()
    @Published var startDate: Date = UserDefaults.standard.object(forKey: "userStartDate") as? Date ?? Date()
    @Published var level: Int = UserDefaults.standard.integer(forKey: "userLevel") == 0 ? 1 : UserDefaults.standard.integer(forKey: "userLevel")
    @Published var xp: Int = UserDefaults.standard.integer(forKey: "userXP")
    @Published var profileImagePath: String? = UserDefaults.standard.string(forKey: "userProfileImagePath")
    
    var profileImage: UIImage? {
        if let path = profileImagePath,
           let imageData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            return UIImage(data: imageData)
        }
        return nil
    }

    var goal: Int = UserDefaults.standard.integer(forKey: "userGoal") == 0 ? 3 : UserDefaults.standard.integer(forKey: "userGoal")

    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    /// Update streak data based on completed days
    func updateStreaks() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Add all completed days to streakDates
        for (dateString, day) in days where day.isComplete {
            let date = User.createDate(from: dateString)
            if !streakDates.contains(date) {
                streakDates.append(date)
            }
        }
        
        // Filter out future dates and sort
        streakDates = streakDates.filter { $0 <= today }.sorted()

        // Calculate current streak
        var currentStreak = 0
        var lastDate = today

        for date in streakDates.reversed() {
            if calendar.dateComponents([.day], from: date, to: lastDate).day ?? Int.max <= 1 {
                currentStreak += 1
                lastDate = date
            } else {
                break
            }
        }

        // Add today to streakDates if completed
        if !streakDates.contains(today), days[EntryView.createDayString(from: today)]?.isComplete == true {
            streakDates.append(today)
            currentStreak += 1
        }
        
        // Add XP for the current streak
        addXP(currentStreak * 10)

        // Update longest streak
        longestStreak = max(longestStreak, currentStreak)

        // Save updates
        save()
    }
    
    /// Save user-related data
    func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(name, forKey: "userName")
        defaults.set(hasReminder, forKey: "hasReminder")
        defaults.set(reminderTime, forKey: "userReminderTime")
        defaults.set(boughtMulti, forKey: "userBoughtMulti")
        defaults.set(xpMultiplier, forKey: "userXPMultiplier")
        defaults.set(longestStreak, forKey: "userLongestStreak")
        defaults.set(level, forKey: "userLevel")
        defaults.set(xp, forKey: "userXP")
        defaults.set(startDate.timeIntervalSince1970, forKey: "userStartDate")
        defaults.set(goal, forKey: "userGoal")
        
        if let colorComponents = UIColor(color).cgColor.components {
            defaults.set(Array(colorComponents.prefix(4)), forKey: "userColor")
        }
        
        if let profileImagePath = profileImagePath {
            defaults.set(profileImagePath, forKey: "userProfileImagePath")
        }
        
        let encodedStreaks = streakDates.map { $0.timeIntervalSince1970 }
        defaults.set(encodedStreaks, forKey: "userStreakDates")
        
        let encodedDays = days.mapValues { $0.encode() }
        defaults.set(encodedDays, forKey: "userDays")
    }
    
    /// Save profile image
    func saveProfileImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let filePath = getDocumentsDirectory().appendingPathComponent("profile.jpg")
        try? imageData.write(to: filePath)
        profileImagePath = filePath.path
    }
    
    // MARK: - Private Helpers
    func addXP(_ amount: Int) {
        xp += amount

        // Check if XP exceeds the threshold for the next level
        let xpToNextLevel = level * 20 - 10
        if xp >= xpToNextLevel {
            levelUp()
        }
    }
    
    private func levelUp() {
        xp -= level * 20 - 10  // Carry over excess XP
        level += 1
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static func loadColor() -> Color {
        if let components = UserDefaults.standard.array(forKey: "userColor") as? [CGFloat], components.count >= 3 {
            return Color(
                red: components[0],
                green: components[1],
                blue: components[2],
                opacity: components.count == 4 ? components[3] : 1.0
            )
        }
        return .blue
    }
    
    static func createDate(from dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: dateString) ?? Date()
    }

    // Helper function to load streak dates
    static func loadStreakDates() -> [Date] {
        let defaults = UserDefaults.standard
        if let savedStreakDates = defaults.array(forKey: "userStreakDates") as? [Double] {
            return savedStreakDates.map { Date(timeIntervalSince1970: $0) }
        }
        return []
    }

    // Helper function to load days
    static func loadDays() -> [String: Day] {
        if let savedDays = UserDefaults.standard.dictionary(forKey: "userDays") as? [String: Data] {
            return savedDays.compactMapValues { Day.decode(from: $0) }
        }
        return [:]
    }
}
