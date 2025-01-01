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
//        .onAppear {
////            checkUserStreak()
//        }
    }

    // Function to check and reset the streak if necessary
//    private func checkUserStreak() {
//        if let lastStreakDate = user.streakDates.last {
//            if Calendar.current.dateComponents([.day], from: lastStreakDate, to: Date()).day ?? 0 > 1 {
//                user.streakDates.removeAll()
//                saveUserData()
//            }
//        }
//    }

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

// Placeholder Views for Tabs
struct EntryView: View {
    var body: some View {
        VStack {
            Text("What went well today?")
                .font(.headline)
                .padding()
            Spacer()
            // Dynamic entry fields can be added here
        }
    }
}

struct CalendarView: View {
    var body: some View {
        VStack {
            Text("Calendar")
                .font(.headline)
                .padding()
            Spacer()
            // Calendar functionality can be added here
        }
    }
}

struct HistoryView: View {
    var body: some View {
        VStack {
            Text("History")
                .font(.headline)
                .padding()
            Spacer()
            // History-related features can be added here
        }
    }
}

struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Profile")
                .font(.headline)
                .padding()
            Spacer()
            // Profile details can be displayed here
        }
    }
}

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.headline)
                .padding()
            Spacer()
            // Settings options can be added here
        }
    }
}


#Preview {
    MainAppView()
}
