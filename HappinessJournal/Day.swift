//
//  Day.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 1/2/25.
//

import SwiftUI

struct Day: Codable {
    var entries: [String]

    init(entries: [String]) {
        self.entries = entries
    }

    func encode() -> Data? {
        try? JSONEncoder().encode(self)
    }

    static func decode(from data: Data) -> Day? {
        try? JSONDecoder().decode(Day.self, from: data)
    }
}
