import UserNotifications

enum NotificationService {

    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    // MARK: - Daily check-in reminder

    static func scheduleDailyCheckIn(hour: Int = 20, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "How are you today?"
        content.body = "Take a moment to check in. Your vault is keeping things safe."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_checkin", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Milestone notifications

    static func scheduleMilestone(day: Int, unlockDate: Date) {
        let messages: [Int: (String, String)] = [
            7:  ("One week.", "The hardest part is behind you. The first week takes more strength than people realize."),
            14: ("Two weeks.", "Urges peak in week 1-2 and drop sharply after. You're past the peak."),
            21: ("Three weeks.", "Your brain is forming new neural pathways that don't include them."),
            30: ("One month.", "Research shows depressive symptoms return to baseline within 3 months. You're a third of the way there."),
            45: ("Halfway.", "Stress hormones typically normalize around now. Your body is catching up with your decision."),
            60: ("Two months.", "You've done something most people can't. That takes real strength."),
            90: ("Ninety days.", "You made it.")
        ]

        guard let (title, body) = messages[day] else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        guard let triggerDate = Calendar.current.date(
            byAdding: .day, value: day,
            to: Calendar.current.startOfDay(for: unlockDate.addingTimeInterval(-Double(60 * 86400)))
        ) else { return }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "milestone_\(day)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Vault unlocked notification

    static func scheduleUnlockNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Your vault is ready."
        content.body = "The timer has ended. You have a choice to make."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "vault_unlocked", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
