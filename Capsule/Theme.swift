import SwiftUI

// MARK: - Design System

enum Theme {

    // MARK: Colors

    static let background = Color.black
    static let surface = Color(red: 0.10, green: 0.10, blue: 0.10)           // #1A1A1A
    static let surfaceElevated = Color(red: 0.16, green: 0.16, blue: 0.16)   // #2A2A2A
    static let accent = Color(red: 0.96, green: 0.65, blue: 0.14)            // #F5A623 warm amber
    static let textPrimary = Color(red: 0.96, green: 0.96, blue: 0.96)       // #F5F5F5
    static let textSecondary = Color(red: 0.56, green: 0.56, blue: 0.58)     // #8E8E93
    static let destructive = Color(red: 1.00, green: 0.23, blue: 0.19)       // #FF3B30
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)           // #34C759

    // MARK: Mood Palette

    static let moodDevastated = Color(red: 0.35, green: 0.34, blue: 0.84)    // deep indigo
    static let moodSad = Color(red: 0.00, green: 0.48, blue: 1.00)           // blue
    static let moodNeutral = Color(red: 0.56, green: 0.56, blue: 0.58)       // gray
    static let moodOkay = Color(red: 0.96, green: 0.65, blue: 0.14)          // amber
    static let moodGood = Color(red: 0.20, green: 0.78, blue: 0.35)          // green
    static let moodGreat = Color(red: 1.00, green: 0.84, blue: 0.04)         // gold

    // MARK: Typography

    static let largeTitle  = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title       = Font.system(.title, design: .rounded, weight: .bold)
    static let title2      = Font.system(.title2, design: .rounded, weight: .semibold)
    static let headline    = Font.system(.headline, design: .rounded, weight: .semibold)
    static let body        = Font.system(.body, design: .rounded)
    static let callout     = Font.system(.callout, design: .rounded)
    static let caption     = Font.system(.caption, design: .rounded)
    static let counter     = Font.system(size: 64, weight: .bold, design: .rounded)

    // MARK: Animation

    static let spring      = Animation.spring(response: 0.6, dampingFraction: 0.78)
    static let springSnap  = Animation.spring(response: 0.35, dampingFraction: 0.7)
    static let gentle      = Animation.easeInOut(duration: 0.4)
    static let slow        = Animation.easeInOut(duration: 1.2)
    static let breathe     = Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)

    // MARK: Layout

    static let padding: CGFloat       = 24
    static let cardPadding: CGFloat   = 20
    static let cornerRadius: CGFloat  = 20
    static let smallRadius: CGFloat   = 12
}

// MARK: - Card Modifier

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Theme.cardPadding)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}

extension View {
    func card() -> some View {
        modifier(CardStyle())
    }
}
