//
//  CalendarView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject private var user = User.sharedUser
    @State private var currentDate = Date()
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack {
                Text("Calendar")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text(currentDate, formatter: monthFormatter)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(.bottom, 10)
                
                // Month navigation buttons
                HStack {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 20)

                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.top, 40)

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                // Weekday labels
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
                
                // Day buttons
                ForEach(daysInMonth(), id: \.self) { day in
                    if let day = day {
                        Button(action: {
                            dayPressed(day: day)
                        }) {
                            Text("\(day)")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(10)
                                .background(buttonBackground(for: day))
                                .cornerRadius(8)
                                .foregroundColor(buttonTextColor(for: day))
                        }
                    } else {
                        Text("") // Empty cell for alignment
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.2).edgesIgnoringSafeArea(.all))
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
        currentDate = Calendar.current.date(byAdding: .month, value: months, to: currentDate) ?? currentDate
    }
    
    private func dayPressed(day: Int) {
        let selectedDate = Calendar.current.date(bySetting: .day, value: day, of: currentDate) ?? currentDate
        print("Selected Date: \(selectedDate)")
        // Navigate to the corresponding entry view or perform desired action
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
    
    // Formatter for the month and year
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
