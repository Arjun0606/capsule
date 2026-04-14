import SwiftUI
import SwiftData
import PhotosUI

enum OnboardingStep: Int, CaseIterable {
    case welcome
    case contentSelection
    case timerSelection
    case lockCeremony
}

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var context
    @State private var step: OnboardingStep = .welcome
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImageData: [(Data, String?)] = []  // (imageData, assetID)
    @State private var durationDays: Int = 60
    @State private var isLocking = false

    let vaultService: VaultService
    let photoService: PhotoService
    var onComplete: (Vault) -> Void

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            switch step {
            case .welcome:
                WelcomeView {
                    withAnimation(Theme.spring) { step = .contentSelection }
                }

            case .contentSelection:
                ContentSelectionView(
                    selectedPhotos: $selectedPhotos,
                    selectedImageData: $selectedImageData
                ) {
                    withAnimation(Theme.spring) { step = .timerSelection }
                }

            case .timerSelection:
                TimerSelectionView(durationDays: $durationDays) {
                    withAnimation(Theme.spring) { step = .lockCeremony }
                    Task { await performLock() }
                }

            case .lockCeremony:
                LockCeremonyView(
                    itemCount: selectedImageData.count,
                    durationDays: durationDays,
                    isLocking: isLocking
                ) {
                    if let vault = fetchActiveVault() {
                        onComplete(vault)
                    }
                }
            }
        }
    }

    // MARK: - Lock Logic

    private func performLock() async {
        isLocking = true
        let vault = Vault(durationDays: durationDays)
        context.insert(vault)

        for (imageData, _) in selectedImageData {
            do {
                let fileName = try vaultService.encryptAndStore(data: imageData)
                let thumbData = imageData // simplified — in production, resize
                let thumbName = try vaultService.encryptAndStore(data: thumbData)
                let item = VaultItem(type: .photo, encryptedFileName: fileName)
                item.thumbnailFileName = thumbName
                item.vault = vault
                context.insert(item)
            } catch {
                continue
            }
        }

        vault.itemCount = selectedImageData.count
        try? context.save()

        // Schedule notifications
        NotificationService.scheduleUnlockNotification(at: vault.unlockDate)
        for milestone in [7, 14, 21, 30, 45, 60, 90] where milestone <= durationDays {
            NotificationService.scheduleMilestone(day: milestone, unlockDate: vault.unlockDate)
        }
        NotificationService.scheduleDailyCheckIn()

        isLocking = false
    }

    private func fetchActiveVault() -> Vault? {
        let descriptor = FetchDescriptor<Vault>(
            predicate: #Predicate { $0.state == "locked" },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try? context.fetch(descriptor).first
    }
}
