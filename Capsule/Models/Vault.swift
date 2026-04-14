import Foundation
import SwiftData

enum VaultState: String, Codable {
    case locked
    case cooldown
    case unlocked
    case incinerated
    case restored
}

@Model
final class Vault {
    var id: UUID = UUID()
    var label: String = "Vault"
    var createdAt: Date = Date()
    var unlockDate: Date = Date()
    var durationDays: Int = 60
    var state: String = VaultState.locked.rawValue
    var cooldownStartedAt: Date?
    var itemCount: Int = 0
    var urgesResisted: Int = 0
    var streakDays: Int = 0
    var lastStreakDate: Date?

    @Relationship(deleteRule: .cascade, inverse: \VaultItem.vault)
    var items: [VaultItem] = []

    @Relationship(deleteRule: .cascade, inverse: \MoodEntry.vault)
    var moods: [MoodEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \UrgeEvent.vault)
    var urges: [UrgeEvent] = []

    @Relationship(deleteRule: .cascade, inverse: \JournalEntry.vault)
    var journal: [JournalEntry] = []

    var vaultState: VaultState {
        get { VaultState(rawValue: state) ?? .locked }
        set { state = newValue.rawValue }
    }

    var daysElapsed: Int {
        max(0, Calendar.current.dateComponents([.day], from: createdAt, to: .now).day ?? 0)
    }

    var daysRemaining: Int {
        max(0, Calendar.current.dateComponents([.day], from: .now, to: unlockDate).day ?? 0)
    }

    var progress: Double {
        guard durationDays > 0 else { return 0 }
        return min(1.0, Double(daysElapsed) / Double(durationDays))
    }

    var isExpired: Bool { Date.now >= unlockDate }

    var isCooldownActive: Bool {
        guard vaultState == .cooldown, let start = cooldownStartedAt else { return false }
        return Date.now < start.addingTimeInterval(24 * 3600)
    }

    var cooldownEnd: Date? {
        cooldownStartedAt?.addingTimeInterval(24 * 3600)
    }

    func recordUrgeResisted() {
        urgesResisted += 1
        let today = Calendar.current.startOfDay(for: .now)
        if let last = lastStreakDate, Calendar.current.isDate(last, inSameDayAs: today) { return }
        if let last = lastStreakDate,
           Calendar.current.dateComponents([.day], from: last, to: today).day == 1 {
            streakDays += 1
        } else {
            streakDays = 1
        }
        lastStreakDate = today
    }

    init(durationDays: Int, label: String = "Vault") {
        self.id = UUID()
        self.label = label
        self.durationDays = durationDays
        self.createdAt = .now
        self.unlockDate = Calendar.current.date(byAdding: .day, value: durationDays, to: .now) ?? .now
        self.state = VaultState.locked.rawValue
    }
}
