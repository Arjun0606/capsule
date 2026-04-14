import Foundation
import SwiftData

enum UrgeOutcome: String, Codable {
    case resisted
    case brokeOpen
}

@Model
final class UrgeEvent {
    var id: UUID = UUID()
    var date: Date = Date()
    var outcome: String = UrgeOutcome.resisted.rawValue
    var vault: Vault?

    var urgeOutcome: UrgeOutcome {
        get { UrgeOutcome(rawValue: outcome) ?? .resisted }
        set { outcome = newValue.rawValue }
    }

    init(outcome: UrgeOutcome) {
        self.id = UUID()
        self.date = .now
        self.outcome = outcome.rawValue
    }
}
