//
//  EntryView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//


import SwiftUI

struct EntryView: View {
    var date: Date // Accepts a specific date to display entries
    var day: Day? // Optional Day object to pass specific data
    @ObservedObject private var user = User.sharedUser
    @State private var entries: [String]

    init(date: Date, day: Day?) {
        self.date = date
        self.day = day
        _entries = State(initialValue: day?.entries ?? EntryView.getEntries(for: date))
    }

    var body: some View {
        VStack {
            // Header
            VStack(spacing: 10) {
                Text("What went well today?")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text(date, style: .date)
                    .font(.title3)
                    .foregroundColor(.blue)
                
                // Current Streak
                HStack(spacing: 5) {
                    Text("🔥")
                        .font(.title3)
                    Text("Streak: \(user.streakDates.count) days")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 20)

            Spacer() // Pushes header up

            // Entry Fields with evenly spaced distribution
            VStack(spacing: 50) {
                ForEach(entries.indices, id: \.self) { index in
                    HStack(spacing: 16) {
                        Image(systemName: "smiley")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                        
                        TextField("Press here to begin typing...", text: $entries[index])
                            .padding()
                            .frame(height: 80) // Larger text box
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .onChange(of: entries[index]) { _, _ in
                                saveEntries()
                            }
                    }
                    .padding(.horizontal, 20)
                }
            }

            Spacer() // Pushes the fields upward for even spacing
        }
        .padding(.bottom, 80) // Prevents crowding at the bottom
        .background(Color.blue.opacity(0.2).edgesIgnoringSafeArea(.all))
        .onAppear {
            updateEntries(for: date)
        }
    }

    private func saveEntries() {
        let dayString = EntryView.createDayString(from: date)
        if !user.days.keys.contains(dayString) {
            user.days[dayString] = Day(entries: entries)
        } else {
            user.days[dayString]?.entries = entries
        }

        user.updateStreaks()
    }

    private func updateEntries(for date: Date) {
        entries = day?.entries ?? EntryView.getEntries(for: date)
    }

    static func getEntries(for date: Date) -> [String] {
        let dayString = createDayString(from: date)
        return User.sharedUser.days[dayString]?.entries ?? Array(repeating: "", count: User.sharedUser.goal)
    }

    static func createDayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    let today = Date()
    let dayString = EntryView.createDayString(from: today)
    let day = User.sharedUser.days[dayString] ?? Day(entries: Array(repeating: "", count: User.sharedUser.goal))

    return EntryView(date: today, day: day)
}
