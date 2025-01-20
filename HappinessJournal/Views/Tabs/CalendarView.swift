import SwiftUI

struct CalendarView: View {
    @ObservedObject private var user = User.sharedUser
    @State private var currentDate = Date()
    @State private var selectedDate: Date? // Holds the selected date for navigation
    @State private var navigateToEntryView = false // Controls navigation

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("Calendar")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)

                    Text(currentDate, formatter: monthFormatter)
                        .font(.title2)
                        .foregroundColor(.blue)

                    // Month navigation buttons
                    HStack {
                        Button(action: { changeMonth(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 40, height: 40)
                        }

                        Button(action: { changeMonth(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 40, height: 40)
                        }
                    }
                }
                .padding(.top, 30)

                // Weekday labels
                HStack(spacing: 5) {
                    ForEach(Array(weekdays.enumerated()), id: \.0) { index, day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 10) {
                    ForEach(Array(daysInMonth().enumerated()), id: \.0) { index, day in
                        if let day = day {
                            Button(action: {
                                dayPressed(day: day)
                            }) {
                                Text("\(day)")
                                    .frame(width: 40, height: 40)
                                    .background(buttonBackground(for: day))
                                    .cornerRadius(8)
                                    .foregroundColor(buttonTextColor(for: day))
                            }
                        } else {
                            Text("") // Empty cell for alignment
                                .frame(width: 40, height: 40)
                        }
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding()
            .background(Color.blue.opacity(0.2).edgesIgnoringSafeArea(.all))
            .onChange(of: currentDate) { oldDate, currentDate in
                print("Month changed to: \(currentDate)")
            }
            .navigationDestination(isPresented: $navigateToEntryView) {
                if let selectedDate = selectedDate {
                    let dayString = EntryView.createDayString(from: selectedDate)
                    let selectedDay = user.days[dayString] // Fetch the `Day` object
                    EntryView(date: selectedDate, day: selectedDay) // Pass the `Day` object
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func daysInMonth() -> [Int?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let firstDayOfWeek = calendar.component(.weekday, from: calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!)

        // Add empty cells for the start of the month
        var days: [Int?] = Array(repeating: nil, count: firstDayOfWeek - 1)
        days.append(contentsOf: range.map { $0 })

        return days
    }

    private func changeMonth(by months: Int) {
        withAnimation {
            currentDate = Calendar.current.date(byAdding: .month, value: months, to: currentDate) ?? currentDate
        }
    }

    private func dayPressed(day: Int) {
        var components = Calendar.current.dateComponents([.year, .month], from: currentDate)
        components.day = day // Safely set the day component

        if let selectedDate = Calendar.current.date(from: components) {
            self.selectedDate = selectedDate
            self.navigateToEntryView = true // Trigger navigation
        } else {
            print("Error: Unable to create a valid date from the given components")
        }
    }

    private func buttonBackground(for day: Int) -> Color {
        let selectedDate = Calendar.current.date(bySetting: .day, value: day, of: currentDate) ?? currentDate
        let dayString = EntryView.createDayString(from: selectedDate)
        if let day = user.days[dayString], day.isComplete {
            return .blue
        }
        return Color.white
    }

    private func buttonTextColor(for day: Int) -> Color {
        let selectedDate = Calendar.current.date(bySetting: .day, value: day, of: currentDate) ?? currentDate
        return selectedDate <= Date() ? .black : .gray
    }

    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    private var weekdays: [String] {
        let formatter = DateFormatter()
        formatter.locale = .current
        return formatter.veryShortWeekdaySymbols
    }
}

#Preview {
    CalendarView()
}
