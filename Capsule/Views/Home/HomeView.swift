import SwiftUI
import SwiftData

struct HomeView: View {
    let vault: Vault
    let vaultService: VaultService

    @Environment(\.modelContext) private var context
    @State private var showUrgeView = false
    @State private var showSettings = false
    @State private var showJournal = false
    @State private var showInsights = false
    @State private var showPaywall = false
    @State private var todayMoodLogged = false
    @State private var selectedMood: Mood?
    @State private var showAffectLabels = false
    @State private var selectedLabels: Set<AffectLabel> = []
    @State private var breathing = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 12)

                    // MARK: - Lock + Progress Ring
                    ZStack {
                        ProgressRing(progress: vault.progress)

                        VStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Theme.accent)
                                .scaleEffect(breathing ? 1.05 : 0.95)
                                .animation(Theme.breathe, value: breathing)

                            Text("Day \(vault.daysElapsed)")
                                .font(Theme.counter)
                                .foregroundStyle(Theme.textPrimary)

                            Text("\(vault.daysRemaining) days remaining")
                                .font(Theme.callout)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .onAppear { breathing = true }

                    // MARK: - Stats Row
                    HStack(spacing: 16) {
                        StatCard(
                            icon: "photo.fill",
                            value: "\(vault.itemCount)",
                            label: "locked"
                        )
                        StatCard(
                            icon: "hand.raised.fill",
                            value: "\(vault.urgesResisted)",
                            label: "resisted"
                        )
                        StatCard(
                            icon: "flame.fill",
                            value: "\(vault.streakDays)",
                            label: "day streak"
                        )
                    }

                    // MARK: - Mood Check-In
                    if !todayMoodLogged {
                        MoodCheckInCard(
                            selectedMood: $selectedMood,
                            showAffectLabels: $showAffectLabels,
                            selectedLabels: $selectedLabels
                        ) {
                            logMood()
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Theme.success)
                            Text("Checked in today")
                                .font(Theme.callout)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .card()
                    }

                    // MARK: - Milestone Insight
                    if let insight = currentInsight {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Day \(insight.day)")
                                .font(Theme.caption)
                                .foregroundStyle(Theme.accent)
                            Text(insight.message)
                                .font(Theme.callout)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .card()
                    }

                    // MARK: - Action Buttons
                    VStack(spacing: 12) {
                        CapsuleButton(title: "Write an unsent letter", icon: "pencil.line", style: .secondary) {
                            showJournal = true
                        }

                        CapsuleButton(title: "View recovery graph", icon: "chart.line.uptrend.xyaxis", style: .secondary) {
                            showInsights = true
                        }

                        // The vault tap area — urge trigger
                        Button {
                            showUrgeView = true
                        } label: {
                            HStack {
                                Image(systemName: "eye.slash.fill")
                                    .foregroundStyle(Theme.textSecondary)
                                Text("I want to look...")
                                    .font(Theme.callout)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, Theme.padding)
            }
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Capsule")
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .fullScreenCover(isPresented: $showUrgeView) {
                UrgeView(vault: vault, vaultService: vaultService)
            }
            .sheet(isPresented: $showJournal) {
                UnsentLetterView(vault: vault)
            }
            .sheet(isPresented: $showInsights) {
                RecoveryGraphView(vault: vault)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(vault: vault, vaultService: vaultService)
            }
            .onAppear {
                vaultService.checkAndUpdateState(vault)
                checkTodayMood()
            }
        }
    }

    // MARK: - Helpers

    private func logMood() {
        guard let mood = selectedMood else { return }
        let entry = MoodEntry(mood: mood, labels: Array(selectedLabels))
        entry.vault = vault
        context.insert(entry)
        try? context.save()
        HapticsService.light()
        withAnimation(Theme.spring) { todayMoodLogged = true }
    }

    private func checkTodayMood() {
        let today = Calendar.current.startOfDay(for: .now)
        todayMoodLogged = vault.moods.contains { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    private var currentInsight: (day: Int, message: String)? {
        let day = vault.daysElapsed
        let milestones: [(Int, String)] = [
            (7, "The first week is the hardest. Cortisol levels are at their peak. They will start declining this week."),
            (14, "Urges peak in week 1-2 and drop sharply after. You're past the peak."),
            (21, "Your brain is forming new neural pathways that don't include them."),
            (30, "Research shows depressive symptoms return to baseline within 3 months. You're a third of the way there."),
            (45, "Stress hormones typically normalize around now. Your body is catching up with your decision."),
            (60, "You've done something most people can't. That takes real strength."),
            (90, "You made it."),
        ]
        return milestones.last { $0.0 <= day }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Theme.accent)
            Text(value)
                .font(Theme.title2)
                .foregroundStyle(Theme.textPrimary)
            Text(label)
                .font(Theme.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .card()
    }
}

// MARK: - Mood Check-In Card

struct MoodCheckInCard: View {
    @Binding var selectedMood: Mood?
    @Binding var showAffectLabels: Bool
    @Binding var selectedLabels: Set<AffectLabel>
    let onLog: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("How are you today?")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)

            // Mood faces
            HStack(spacing: 12) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Button {
                        HapticsService.light()
                        withAnimation(Theme.springSnap) {
                            selectedMood = mood
                            showAffectLabels = true
                        }
                    } label: {
                        Text(mood.emoji)
                            .font(.system(size: selectedMood == mood ? 36 : 28))
                            .scaleEffect(selectedMood == mood ? 1.15 : 1.0)
                            .opacity(selectedMood == nil || selectedMood == mood ? 1 : 0.4)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Affect labels (Lieberman research)
            if showAffectLabels {
                VStack(spacing: 10) {
                    Text("Put it into words")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.textSecondary)

                    FlowLayout(spacing: 8) {
                        ForEach(AffectLabel.allCases, id: \.self) { label in
                            Button {
                                HapticsService.light()
                                if selectedLabels.contains(label) {
                                    selectedLabels.remove(label)
                                } else {
                                    selectedLabels.insert(label)
                                }
                            } label: {
                                Text(label.display)
                                    .font(Theme.caption)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedLabels.contains(label)
                                            ? Theme.accent : Theme.surfaceElevated
                                    )
                                    .foregroundStyle(
                                        selectedLabels.contains(label)
                                            ? .black : Theme.textSecondary
                                    )
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            if selectedMood != nil {
                CapsuleButton(title: "Log", action: onLog)
                    .transition(.opacity)
            }
        }
        .card()
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
