import SwiftUI
import SwiftData

@main
struct CapsuleApp: App {
    @State private var vaultService = VaultService()
    @State private var photoService = PhotoService()

    var body: some Scene {
        WindowGroup {
            RootView(vaultService: vaultService, photoService: photoService)
        }
        .modelContainer(for: [
            Vault.self,
            VaultItem.self,
            MoodEntry.self,
            UrgeEvent.self,
            JournalEntry.self,
        ])
    }
}

// MARK: - Root Router

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Vault.createdAt, order: .reverse)
    private var allVaults: [Vault]

    let vaultService: VaultService
    let photoService: PhotoService

    private var activeVault: Vault? {
        let active = Set(["locked", "cooldown", "unlocked"])
        return allVaults.first { active.contains($0.state) }
    }

    var body: some View {
        content
            .preferredColorScheme(.dark)
            .onAppear {
                if let vault = activeVault {
                    vaultService.checkAndUpdateState(vault)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if let vault = activeVault {
            if vault.vaultState == .unlocked || vault.isExpired {
                UnlockCeremonyView(vault: vault, vaultService: vaultService)
            } else {
                HomeView(vault: vault, vaultService: vaultService)
            }
        } else {
            OnboardingContainerView(
                vaultService: vaultService,
                photoService: photoService
            ) { _ in }
        }
    }
}
