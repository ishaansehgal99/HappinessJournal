//
//  HistoryView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject private var user = User.sharedUser
    @State private var selectedFilter: HistoryFilter = .pastWeek
    @State private var filteredEntries: [HistoryEntry] = []

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("History")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .padding(.top, 20)

            // Filter (Segmented Control)
            Picker("Filter", selection: $selectedFilter) {
                ForEach(HistoryFilter.allCases, id: \.self) { filter in
                    Text(filter.displayName).tag(filter)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            .onChange(of: selectedFilter) { _ in
                filterEntries()
            }

            // Entries
            if filteredEntries.isEmpty {
                Spacer()
                Text("No Entries")
                    .font(.title3)
                    .foregroundColor(.gray)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(filteredEntries) { entry in
                            HistoryBoxView(entry: entry)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.2).edgesIgnoringSafeArea(.all))
        .onAppear(perform: filterEntries)
    }

    // Filters entries based on the selected filter
    private func filterEntries() {
        let currentDate = Date()
        filteredEntries = user.days
            .flatMap { dayString, day in
                day.entries.compactMap { entry in
                    guard !entry.isEmpty, entry != "Press here to begin typing..." else { return nil }
                    return HistoryEntry(dateString: dayString, entryText: entry)
                }
            }
            .filter { entry in
                guard let entryDate = entry.date else { return false }
                switch selectedFilter {
                case .pastWeek:
                    return currentDate.weeks(from: entryDate) == 0
                case .pastMonth:
                    return currentDate.months(from: entryDate) == 0
                case .pastYear:
                    return currentDate.years(from: entryDate) == 0
                case .allTime:
                    return true
                }
            }
            .sorted { $0.date ?? Date() > $1.date ?? Date() } // Newest to oldest
    }
}

struct HistoryBoxView: View {
    let entry: HistoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let date = entry.date {
                Text(date, formatter: DateFormatter.shortDateFormatter)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(entry.entryText)
                .font(.body)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

// MARK: - Supporting Models and Extensions

struct HistoryEntry: Identifiable {
    let id = UUID()
    let dateString: String
    let entryText: String

    var date: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: dateString)
    }
}

enum HistoryFilter: String, CaseIterable {
    case pastWeek, pastMonth, pastYear, allTime

    var displayName: String {
        switch self {
        case .pastWeek: return "Past Week"
        case .pastMonth: return "Past Month"
        case .pastYear: return "Past Year"
        case .allTime: return "All Time"
        }
    }
}

// DateFormatter for date display
extension DateFormatter {
    static var shortDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

// Extensions for date calculations
extension Date {
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }

    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }

    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
}

#Preview {
    HistoryView()
}
