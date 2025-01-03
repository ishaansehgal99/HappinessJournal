//
//  EntryView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//

import SwiftUI

struct EntryView: View {
    @ObservedObject private var user = User.sharedUser
    @State private var entries: [String]
    @State private var currentDate = Date()
    
    init() {
        _entries = State(initialValue: EntryView.getEntries(for: Date()))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("What went well today?")
                .font(.headline)
                .padding(.top)
            
            // Date Header
            HStack {
                Button(action: { changeDate(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                }
                .disabled(!canMoveBackward())
                
                Spacer()
                
                Text(currentDate, style: .date)
                    .font(.subheadline)
                
                Spacer()
                
                Button(action: { changeDate(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                }
                .disabled(!canMoveForward())
            }
            .padding(.horizontal)
            
            // Entry Fields
            ScrollView {
                ForEach(entries.indices, id: \.self) { index in
                    HStack {
                        Image(systemName: "smiley")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                        
                        TextField("Press here to begin typing...", text: $entries[index])
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .onChange(of: entries[index]) { oldValue, newValue in
                                saveEntries()
                            }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            
            Spacer()
        }
        .background(Color(.systemGray6))
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
    
    private func canMoveForward() -> Bool {
        !Calendar.current.isDateInToday(currentDate)
    }
    
    private func canMoveBackward() -> Bool {
        let daysSinceStart = user.startDate.days(from: currentDate)
        return daysSinceStart > 1
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
