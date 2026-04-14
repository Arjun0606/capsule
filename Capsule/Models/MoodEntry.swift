import Foundation
import SwiftData
import SwiftUI

enum Mood: Int, Codable, CaseIterable {
    case devastated = 1, sad, neutral, okay, good, great

    var emoji: String {
        switch self {
        case .devastated: "😢"
        case .sad:        "😞"
        case .neutral:    "😐"
        case .okay:       "🙂"
        case .good:       "😊"
        case .great:      "😄"
        }
    }

    var label: String {
        switch self {
        case .devastated: "Devastated"
        case .sad:        "Sad"
        case .neutral:    "Neutral"
        case .okay:       "Okay"
        case .good:       "Good"
        case .great:      "Great"
        }
    }

    var color: Color {
        switch self {
        case .devastated: Theme.moodDevastated
        case .sad:        Theme.moodSad
        case .neutral:    Theme.moodNeutral
        case .okay:       Theme.moodOkay
        case .good:       Theme.moodGood
        case .great:      Theme.moodGreat
        }
    }
}

enum AffectLabel: String, Codable, CaseIterable {
    case lonely, angry, sad, numb, anxious, guilty, relieved, hopeful, peaceful, confused
    var display: String { rawValue.capitalized }
}

@Model
final class MoodEntry {
    var id: UUID = UUID()
    var date: Date = Date()
    var moodValue: Int = 3
    var affectLabels: [String] = []
    var note: String?
    var vault: Vault?

    var mood: Mood {
        get { Mood(rawValue: moodValue) ?? .neutral }
        set { moodValue = newValue.rawValue }
    }

    var labels: [AffectLabel] {
        affectLabels.compactMap { AffectLabel(rawValue: $0) }
    }

    init(mood: Mood, labels: [AffectLabel] = [], note: String? = nil) {
        self.id = UUID()
        self.date = .now
        self.moodValue = mood.rawValue
        self.affectLabels = labels.map(\.rawValue)
        self.note = note
    }
}
