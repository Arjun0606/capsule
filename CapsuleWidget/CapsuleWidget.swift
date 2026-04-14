import WidgetKit
import SwiftUI

// MARK: - Shared Data (via App Group / UserDefaults)

struct VaultWidgetData {
    let daysElapsed: Int
    let durationDays: Int
    let daysRemaining: Int
    let urgesResisted: Int
    let streakDays: Int
    let itemCount: Int
    let isLocked: Bool

    var progress: Double {
        guard durationDays > 0 else { return 0 }
        return min(1.0, Double(daysElapsed) / Double(durationDays))
    }

    static let placeholder = VaultWidgetData(
        daysElapsed: 34, durationDays: 60, daysRemaining: 26,
        urgesResisted: 23, streakDays: 12, itemCount: 147, isLocked: true
    )

    static func load() -> VaultWidgetData {
        let defaults = UserDefaults(suiteName: "group.com.capsule.app") ?? .standard
        return VaultWidgetData(
            daysElapsed: defaults.integer(forKey: "widget_daysElapsed"),
            durationDays: max(1, defaults.integer(forKey: "widget_durationDays")),
            daysRemaining: defaults.integer(forKey: "widget_daysRemaining"),
            urgesResisted: defaults.integer(forKey: "widget_urgesResisted"),
            streakDays: defaults.integer(forKey: "widget_streakDays"),
            itemCount: defaults.integer(forKey: "widget_itemCount"),
            isLocked: defaults.bool(forKey: "widget_isLocked")
        )
    }
}

// MARK: - Timeline Provider

struct CapsuleTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> CapsuleWidgetEntry {
        CapsuleWidgetEntry(date: .now, data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (CapsuleWidgetEntry) -> Void) {
        completion(CapsuleWidgetEntry(date: .now, data: .load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CapsuleWidgetEntry>) -> Void) {
        let entry = CapsuleWidgetEntry(date: .now, data: .load())
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct CapsuleWidgetEntry: TimelineEntry {
    let date: Date
    let data: VaultWidgetData
}

// MARK: - Widget Colors (standalone, no Theme dependency)

private let widgetAccent = Color(red: 0.96, green: 0.65, blue: 0.14)
private let widgetBg = Color(red: 0.06, green: 0.06, blue: 0.06)
private let widgetSurface = Color(red: 0.10, green: 0.10, blue: 0.10)
private let widgetTextPrimary = Color(red: 0.96, green: 0.96, blue: 0.96)
private let widgetTextSecondary = Color(red: 0.56, green: 0.56, blue: 0.58)

// MARK: - Small Widget

struct CapsuleSmallView: View {
    let data: VaultWidgetData

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.title2)
                .foregroundStyle(widgetAccent)

            Text("Day \(data.daysElapsed)")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(widgetTextPrimary)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(widgetSurface)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(widgetAccent)
                        .frame(width: geo.size.width * data.progress)
                }
            }
            .frame(height: 5)

            Text("\(data.daysRemaining) days left")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(widgetTextSecondary)
        }
        .padding()
        .containerBackground(widgetBg, for: .widget)
    }
}

// MARK: - Medium Widget

struct CapsuleMediumView: View {
    let data: VaultWidgetData

    var body: some View {
        HStack(spacing: 20) {
            // Left — day counter
            VStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundStyle(widgetAccent)

                Text("Day \(data.daysElapsed)")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(widgetTextPrimary)

                Text("of \(data.durationDays)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(widgetTextSecondary)
            }
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(widgetSurface)
                .frame(width: 1)
                .padding(.vertical, 8)

            // Right — stats
            VStack(alignment: .leading, spacing: 10) {
                WidgetStat(icon: "photo.fill", value: "\(data.itemCount)", label: "locked")
                WidgetStat(icon: "hand.raised.fill", value: "\(data.urgesResisted)", label: "resisted")
                WidgetStat(icon: "flame.fill", value: "\(data.streakDays)", label: "day streak")
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .containerBackground(widgetBg, for: .widget)
    }
}

struct WidgetStat: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(widgetAccent)
                .frame(width: 14)
            Text(value)
                .font(.system(.callout, design: .rounded, weight: .semibold))
                .foregroundStyle(widgetTextPrimary)
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(widgetTextSecondary)
        }
    }
}

// MARK: - Lock Screen Widget

struct CapsuleLockScreenView: View {
    let data: VaultWidgetData

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "lock.fill")
                .font(.caption)
            Text("Day \(data.daysElapsed) / \(data.durationDays)")
                .font(.system(.caption, design: .rounded, weight: .semibold))
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Lock Screen Circular Widget

struct CapsuleLockScreenCircularView: View {
    let data: VaultWidgetData

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 1) {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                Text("\(data.daysElapsed)")
                    .font(.system(.body, design: .rounded, weight: .bold))
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Widget Configuration

struct CapsuleWidget: Widget {
    let kind = "CapsuleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CapsuleTimelineProvider()) { entry in
            switch entry.date {  // trick to get family from context
            default:
                CapsuleSmallView(data: entry.data)
            }
        }
        .configurationDisplayName("Capsule")
        .description("Track your healing progress.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryInline, .accessoryCircular])
    }
}

// MARK: - Widget Bundle

@main
struct CapsuleWidgetBundle: WidgetBundle {
    var body: some Widget {
        CapsuleWidget()
    }
}
