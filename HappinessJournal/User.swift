//
//  User.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//


import SwiftUI

class User: ObservableObject {
    static let sharedUser = User()
    
    @Published var name: String {
        didSet {
            UserDefaults.standard.set(name, forKey: "userName")
        }
    }
    
    @Published var color: Color {
        didSet {
            if let colorComponents = UIColor(color).cgColor.components {
                let rgbaComponents = Array(colorComponents.prefix(4)) // Ensure only R, G, B, A are saved
                UserDefaults.standard.set(rgbaComponents, forKey: "userColor")
            }
        }
    }
    
    private init() {
        // Load name
        self.name = UserDefaults.standard.string(forKey: "userName") ?? ""
        
        // Load color (with backward compatibility for 3-component colors)
        if let components = UserDefaults.standard.array(forKey: "userColor") as? [CGFloat] {
            if components.count >= 4 {
                // Load with opacity
                self.color = Color(
                    red: components[0],
                    green: components[1],
                    blue: components[2],
                    opacity: components[3]
                )
            } else if components.count >= 3 {
                // Load without opacity (default to opaque)
                self.color = Color(
                    red: components[0],
                    green: components[1],
                    blue: components[2],
                    opacity: 1.0
                )
            } else {
                self.color = .blue
            }
        } else {
            self.color = .blue
        }
    }
}

