import SwiftUI

struct EntryView: View {
    @ObservedObject private var user = User.sharedUser
    @State private var entries: [String]
    @State private var currentDate = Date()

    init() {
        _entries = State(initialValue: EntryView.getEntries(for: Date()))
    }

    var body: some View {
        VStack {
            // Header
            VStack(spacing: 10) {
                Text("What went well today?")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text(currentDate, style: .date)
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
                            .onChange(of: entries[index]) { oldValue, newValue in
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
            updateEntries(for: currentDate)
        }
    }

    private func saveEntries() {
        let dayString = EntryView.createDayString(from: currentDate)
        if !user.days.keys.contains(dayString) {
            user.days[dayString] = Day(entries: entries)
        } else {
            user.days[dayString]?.entries = entries
        }
        user.save()
    }

    private func updateEntries(for date: Date) {
        entries = EntryView.getEntries(for: date)
    }

    private func changeDate(by days: Int) {
        currentDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) ?? Date()
        updateEntries(for: currentDate)
    }

    static func getEntries(for date: Date) -> [String] {
        let dayString = createDayString(from: date)
        if let existingDay = User.sharedUser.days[dayString] {
            return existingDay.entries
        } else {
            return Array(repeating: "", count: User.sharedUser.goal)
        }
    }

    static func createDayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    EntryView()
}
