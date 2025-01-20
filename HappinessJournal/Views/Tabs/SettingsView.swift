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
    @State private var selectedTime: Date = Date() // Fallback default

    var body: some View {
        NavigationView {
            Form {
                // Notifications Section
                Section(header: Text("Notifications")) {
                    Toggle("Daily Reminder", isOn: $user.hasReminder)
                        .onChange(of: user.hasReminder) { _, newValue in
                            handleReminderToggle(isOn: newValue)
                        }

                    if user.hasReminder {
                        DatePicker(
                            "Reminder Time",
                            selection: $selectedTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: selectedTime) { _, newTime in
                            updateReminderTime(to: newTime)
                        }
                        .datePickerStyle(WheelDatePickerStyle())
                    }
                }

                // Support Section
                Section(header: Text("Support")) {
                    NavigationLink("About", destination: AboutView())
                    Button("Send Feedback") {
                        sendEmail(to: "threegoodthingscontact@gmail.com")
                    }
                    Button("Rate the App") {
                        rateApp()
                    }
                }

                // Social Media Section
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
            .onAppear {
                initializeSelectedTime()
            }
        }
    }

    // MARK: - Helper Functions

    private func initializeSelectedTime() {
        if let reminderTime = DateFormatter.reminderTimeFormatter.date(from: user.reminderTime) {
            selectedTime = reminderTime
        }
    }

    private func handleReminderToggle(isOn: Bool) {
        if isOn {
            requestNotificationAuthorization { granted in
                if granted {
                    isTimePickerVisible = true
                } else {
                    DispatchQueue.main.async {
                        user.hasReminder = false
                    }
                }
            }
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            isTimePickerVisible = false
        }
    }

    private func updateReminderTime(to time: Date) {
        let formattedTime = DateFormatter.reminderTimeFormatter.string(from: time)
        user.reminderTime = formattedTime
        scheduleNotification(at: time)
    }

    private func requestNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            completion(granted)
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

    private func sendEmail(to email: String) {
        if let emailURL = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(emailURL) {
            UIApplication.shared.open(emailURL)
        } else {
            print("Unable to open email URL.")
        }
    }

    private func rateApp() {
        let appID = "1242079576" // Replace with your App Store ID
        if let url = URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Unable to open App Store URL.")
        }
    }

    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Unable to open URL: \(urlString)")
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack {
            Text("Three Good Things is a Happiness Journal designed to help you reflect on the positives in life.")
                .font(.body)
                .padding()
            Spacer()
        }
        .navigationTitle("About")
    }
}

extension DateFormatter {
    static let reminderTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}

#Preview {
    SettingsView()
}
