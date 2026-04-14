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
    @Query(filter: #Predicate<Vault> { $0.state == "locked" || $0.state == "cooldown" || $0.state == "unlocked" },
           sort: \Vault.createdAt, order: .reverse)
    private var activeVaults: [Vault]

    let vaultService: VaultService
    let photoService: PhotoService

    var body: some View {
        Group {
            if let vault = activeVaults.first {
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
        .preferredColorScheme(.dark)
        .onAppear {
            if let vault = activeVaults.first {
                vaultService.checkAndUpdateState(vault)
            }
        }
    }
}
