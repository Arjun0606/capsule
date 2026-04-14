import SwiftUI
import Charts
import SwiftData

struct RecoveryGraphView: View {
    let vault: Vault

    @Environment(\.dismiss) private var dismiss

    private var sortedMoods: [MoodEntry] {
        vault.moods.sorted { $0.date < $1.date }
    }

    private var weeklyUrges: [(week: Int, count: Int)] {
        let grouped = Dictionary(grouping: vault.urges.sorted { $0.date < $1.date }) { urge in
            Calendar.current.component(.weekOfYear, from: urge.date)
        }
        return grouped.map { (week: $0.key, count: $0.value.count) }
            .sorted { $0.week < $1.week }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 8)

                    // MARK: - Mood Over Time
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your mood over time")
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)

                        if sortedMoods.count >= 2 {
                            Chart(sortedMoods) { entry in
                                LineMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Mood", entry.moodValue)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(Theme.accent)

                                AreaMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Mood", entry.moodValue)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Theme.accent.opacity(0.3), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )

                                PointMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Mood", entry.moodValue)
                                )
                                .foregroundStyle(entry.mood.color)
                                .symbolSize(40)
                            }
                            .chartYScale(domain: 1...6)
                            .chartYAxis {
                                AxisMarks(values: [1, 3, 6]) { value in
                                    AxisValueLabel {
                                        if let v = value.as(Int.self) {
                                            Text(Mood(rawValue: v)?.emoji ?? "")
                                        }
                                    }
                                }
                            }
                            .frame(height: 200)

                            Text("Bad days are normal. Look at the trend.")
                                .font(Theme.caption)
                                .foregroundStyle(Theme.textSecondary)
                        } else {
                            Text("Check in daily to see your recovery graph build over time.")
                                .font(Theme.callout)
                                .foregroundStyle(Theme.textSecondary)
                                .frame(height: 120)
                        }
                    }
                    .card()

                    // MARK: - Urge Frequency
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Urges over time")
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)

                        if weeklyUrges.count >= 2 {
                            Chart(weeklyUrges, id: \.week) { item in
                                BarMark(
                                    x: .value("Week", "W\(item.week)"),
                                    y: .value("Urges", item.count)
                                )
                                .foregroundStyle(Theme.accent.opacity(0.7))
                                .cornerRadius(4)
                            }
                            .frame(height: 160)

                            Text("Watching this go down is how you know it's working.")
                                .font(Theme.caption)
                                .foregroundStyle(Theme.textSecondary)
                        } else {
                            Text("Urge data will appear as you use the app.")
                                .font(Theme.callout)
                                .foregroundStyle(Theme.textSecondary)
                                .frame(height: 80)
                        }
                    }
                    .card()

                    // MARK: - Affect Label Summary
                    if !vault.moods.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Most frequent feelings")
                                .font(Theme.headline)
                                .foregroundStyle(Theme.textPrimary)

                            let allLabels = vault.moods.flatMap(\.affectLabels)
                            let counts = Dictionary(allLabels.map { ($0, 1) }, uniquingKeysWith: +)
                                .sorted { $0.value > $1.value }
                                .prefix(5)

                            ForEach(Array(counts), id: \.key) { label, count in
                                HStack {
                                    Text(label.capitalized)
                                        .font(Theme.callout)
                                        .foregroundStyle(Theme.textPrimary)
                                    Spacer()
                                    Text("\(count)x")
                                        .font(Theme.caption)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }
                        }
                        .card()
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, Theme.padding)
            }
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Recovery")
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }
}
