//
//  MainAppView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//

import SwiftUI

struct MainAppView: View {
    @ObservedObject private var user = User.sharedUser
    @State private var selectedTab: Tab = .entry

    var body: some View {
        TabView(selection: $selectedTab) {
            EntryView()
                .tabItem {
                    Label("Entry", systemImage: "book")
                }
                .tag(Tab.entry)

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(Tab.calendar)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(Tab.history)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        .accentColor(user.color)
        .onAppear {
            checkUserStreak()
        }
    }

    // Function to check and reset the streak if necessary
    private func checkUserStreak() {
        if let lastStreakDate = user.streakDates.last {
            if Calendar.current.dateComponents([.day], from: lastStreakDate, to: Date()).day ?? 0 > 1 {
                user.streakDates.removeAll()
            }
        }
    }

    // Save user data to persist changes
    private func saveUserData() {
        let savedData = try? NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
        UserDefaults.standard.set(savedData, forKey: "user")
    }
}

// Enum for tabs
enum Tab: Hashable {
    case entry, calendar, history, profile, settings
}

#Preview {
    MainAppView()
}
