//
//  SettingsView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @ObservedObject private var user = User.sharedUser
    @State private var isTimePickerVisible = false
    @State private var selectedTime = Date()
    @State private var showAboutView = false
    @State private var showFeedbackView = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Daily Reminder", isOn: $user.hasReminder)
                        .onChange(of: user.hasReminder) { oldReminder, newReminder in
                            if newReminder {
                                requestNotificationAuthorization()
                                isTimePickerVisible = true
                            } else {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                isTimePickerVisible = false
                            }
                        }

                    if user.hasReminder && isTimePickerVisible {
                        DatePicker(
                            "Reminder Time",
                            selection: $selectedTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: selectedTime) { oldTime, newTime in
                            user.reminderTime = formatTime(newTime)
                            scheduleNotification(at: newTime)
                        }
                        .datePickerStyle(WheelDatePickerStyle())
                    }
                }

                Section(header: Text("Support")) {
                    Button("About") {
                        showAboutView = true
                    }
                    Button("Send Feedback") {
                        sendEmail(to: "threegoodthingscontact@gmail.com")
                    }
                    Button("Rate the App") {
                        rateApp()
                    }
                }

                Section(header: Text("Social Media")) {
                    Button("Visit Facebook") {
                        openURL("https://www.facebook.com/Three-Good-Things-A-Happiness-Journal-for-iOS-1793191400995847/")
                    }
                    Button("Visit Twitter") {
                        openURL("https://twitter.com/_3_good_things")
                    }
                }
            }

            .navigationTitle("Settings")
            .sheet(isPresented: $showAboutView) {
                AboutView()
            }
        }
    }

    // MARK: - Helper Functions

    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if !granted {
                DispatchQueue.main.async {
                    user.hasReminder = false
                }
            }
        }
    }

    private func scheduleNotification(at time: Date) {
        let content = UNMutableNotificationContent()
        content.body = "What are three things that went well today?"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let request = UNNotificationRequest(identifier: "DailyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func sendEmail(to email: String) {
        if let emailURL = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(emailURL) {
            UIApplication.shared.open(emailURL)
        }
    }

    private func rateApp() {
        let appID = "1242079576" // Replace with your App Store ID
        if let url = URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)") {
            UIApplication.shared.open(url)
        }
    }

    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack {
            Text("About")
                .font(.largeTitle)
                .padding()
            Spacer()
            Text("Three Good Things is a Happiness Journal designed to help you reflect on the positives in life.")
                .font(.body)
                .padding()
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
