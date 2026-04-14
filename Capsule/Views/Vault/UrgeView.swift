import SwiftUI
import SwiftData

struct UrgeView: View {
    let vault: Vault
    let vaultService: VaultService

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showBreakLock = false
    @State private var showContent = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Lock icon
                VStack(spacing: 32) {
                    ZStack {
                        Circle()
                            .fill(Theme.accent.opacity(0.08))
                            .frame(width: 140, height: 140)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundStyle(Theme.accent)
                    }

                    VStack(spacing: 16) {
                        Text("The vault is locked.")
                            .font(Theme.title2)
                            .foregroundStyle(Theme.textPrimary)

                        Text("You're here because\nyou want to look.")
                            .font(Theme.body)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)

                        if vault.urgesResisted > 0 {
                            Text("You've felt this \(vault.urgesResisted) times.\nYou've beaten it \(vault.urgesResisted) times.")
                                .font(Theme.callout)
                                .foregroundStyle(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                        }
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                Spacer()

                // Actions
                VStack(spacing: 16) {
                    CapsuleButton(title: "I don't need to look.", icon: "checkmark", action: resistUrge)

                    Button {
                        HapticsService.warning()
                        showBreakLock = true
                    } label: {
                        Text("I want to break the lock")
                            .font(Theme.caption)
                            .foregroundStyle(Theme.textSecondary.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, Theme.padding)
        }
        .fullScreenCover(isPresented: $showBreakLock) {
            BreakLockView(vault: vault, vaultService: vaultService)
        }
        .onAppear {
            withAnimation(Theme.gentle.delay(0.2)) { showContent = true }
        }
    }

    private func resistUrge() {
        vault.recordUrgeResisted()
        let urge = UrgeEvent(outcome: .resisted)
        urge.vault = vault
        context.insert(urge)
        try? context.save()
        HapticsService.urgeResisted()
        dismiss()
    }
}
