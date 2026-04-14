import SwiftUI
import SwiftData

struct BreakLockView: View {
    let vault: Vault
    let vaultService: VaultService

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showContent = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.destructive)

                    Text("Are you sure?")
                        .font(Theme.title)
                        .foregroundStyle(Theme.textPrimary)

                    if vault.streakDays > 0 {
                        Text("You're on a \(vault.streakDays)-day streak.")
                            .font(Theme.body)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        BulletPoint("Reset your streak to 0")
                        BulletPoint("Start a 24-hour cooldown")
                        BulletPoint("You won't see anything today")
                    }
                    .padding(.vertical, 8)

                    Text("If you still want to open the\nvault tomorrow, you can.")
                        .font(Theme.callout)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)

                    Text("Most people don't come back.\nThe urge passes.")
                        .font(Theme.callout)
                        .foregroundStyle(Theme.accent)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .opacity(showContent ? 1 : 0)

                Spacer()

                VStack(spacing: 16) {
                    CapsuleButton(title: "You're right. Go back.", icon: "checkmark", action: {
                        dismiss()
                    })

                    Button {
                        startCooldown()
                    } label: {
                        Text("Start 24-hour cooldown")
                            .font(Theme.caption)
                            .foregroundStyle(Theme.destructive.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
                .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, Theme.padding)
        }
        .onAppear {
            withAnimation(Theme.gentle.delay(0.2)) { showContent = true }
        }
    }

    private func startCooldown() {
        vaultService.startCooldown(vault, context: context)
        HapticsService.warning()
        dismiss()
    }
}

struct BulletPoint: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Theme.destructive)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            Text(text)
                .font(Theme.callout)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}
