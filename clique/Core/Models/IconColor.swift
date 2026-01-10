//
//  IconColor.swift
//  clique
//
//  Created by Clique on 1/9/26.
//

import SwiftUI

/// Represents available icon background colors
enum IconColor: String, CaseIterable, Identifiable {
    case blue = "blue"
    case red = "red"
    case green = "green"
    case orange = "orange"
    case purple = "purple"
    case pink = "pink"
    case yellow = "yellow"
    case cyan = "cyan"
    case mint = "mint"
    case indigo = "indigo"
    
    var id: String { rawValue }
    
    /// The SwiftUI Color for this icon color
    var color: Color {
        switch self {
        case .blue: return .blue
        case .red: return .red
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        case .pink: return .pink
        case .yellow: return .yellow
        case .cyan: return .cyan
        case .mint: return .mint
        case .indigo: return .indigo
        }
    }
    
    /// Display name for the color picker
    var displayName: String {
        rawValue.capitalized
    }
    
    /// Creates an IconColor from a string, defaulting to blue if invalid
    static func from(_ string: String?) -> IconColor {
        guard let string = string, let color = IconColor(rawValue: string) else {
            return .blue
        }
        return color
    }
}
