import SwiftUI

struct EntryView: View {
    var date: Date // Accepts a specific date to display entries
    var day: Day? // Optional Day object to pass specific data
    @ObservedObject private var user = User.sharedUser
    @State private var entries: [String]
    @State private var showFeedback = false // State to control feedback message visibility
    @State private var allEntriesCompleted = false // State for all entries completion feedback

    init(date: Date, day: Day?) {
        self.date = date
        self.day = day
        _entries = State(initialValue: day?.entries ?? EntryView.getEntries(for: date))
    }

    var body: some View {
        ZStack {
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
                            
                            TextField("Press here to begin typing...", text: $entries[index], onCommit: {
                                handleCompletion(for: index)
                            })
                            .padding()
                            .frame(height: 80) // Larger text box
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer() // Pushes the fields upward for even spacing
            }
            .padding(.bottom, 80) // Prevents crowding at the bottom
            .background(Color.blue.opacity(0.2).edgesIgnoringSafeArea(.all))
            .overlay(
                // Feedback message overlay
                Group {
                    if showFeedback {
                        Text("Entry saved!")
                            .font(.headline)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .transition(.opacity)
                            .zIndex(1)
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: showFeedback)
            )

            // Completion Celebration Overlay
            if allEntriesCompleted {
                VStack {
                    Text("🎉 All Entries Completed! 🎉")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(radius: 10)

                    Spacer()
                }
                .zIndex(2)
                .transition(.scale)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            allEntriesCompleted = false
                        }
                    }
                }
            }
        }
        .onAppear {
            updateEntries(for: date)
        }
    }

    private func saveEntries() {
        let dayString = EntryView.createDayString(from: date)

        // Check if the day exists in the user's data
        if !user.days.keys.contains(dayString) {
            user.days[dayString] = Day(entries: entries)
        } else {
            user.days[dayString]?.entries = entries
        }

        // Check if all entries are completed
        if entries.allSatisfy({ !$0.isEmpty }) {
            allEntriesCompleted = true
        }

        // Show individual entry feedback
        showFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showFeedback = false
        }

        // Update streaks after marking the day complete
        user.updateStreaks()
    }

    private func handleCompletion(for index: Int) {
        // Show feedback only for meaningful input
        if entries[index].count > 0 {
            saveEntries()
        }
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
