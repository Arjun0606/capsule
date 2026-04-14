import SwiftUI
import PhotosUI

struct ContentSelectionView: View {
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Binding var selectedImageData: [(Data, String?)]
    @State private var isLoading = false
    @State private var showPicker = false

    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            // Header
            VStack(spacing: 12) {
                Text("What do you need\nspace from?")
                    .font(Theme.title)
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Select photos, screenshots, anything\nthat pulls you back.")
                    .font(Theme.callout)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer().frame(height: 40)

            // Selection area
            if selectedImageData.isEmpty {
                // Empty state — tap to select
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 100,
                    matching: .any(of: [.images, .screenshots, .videos])
                ) {
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                                .strokeBorder(Theme.textSecondary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                                .frame(height: 200)

                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Theme.textSecondary)

                                Text("Tap to select photos")
                                    .font(Theme.headline)
                                    .foregroundStyle(Theme.textSecondary)

                                Text("You choose what goes in.\nOnly you know what hurts.")
                                    .font(Theme.caption)
                                    .foregroundStyle(Theme.textSecondary.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                }
            } else {
                // Selected photos grid
                VStack(spacing: 16) {
                    HStack {
                        Text("\(selectedImageData.count) items selected")
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)

                        Spacer()

                        PhotosPicker(
                            selection: $selectedPhotos,
                            maxSelectionCount: 100,
                            matching: .any(of: [.images, .screenshots, .videos])
                        ) {
                            Text("Change")
                                .font(Theme.callout)
                                .foregroundStyle(Theme.accent)
                        }
                    }

                    // Thumbnail grid
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 4), spacing: 4) {
                            ForEach(0..<min(selectedImageData.count, 20), id: \.self) { i in
                                if let image = UIImage(data: selectedImageData[i].0) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                            }

                            if selectedImageData.count > 20 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Theme.surfaceElevated)
                                        .frame(height: 80)

                                    Text("+\(selectedImageData.count - 20)")
                                        .font(Theme.headline)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 260)
                }
                .card()
            }

            Spacer()

            // Continue button
            if !selectedImageData.isEmpty {
                CapsuleButton(
                    title: "Lock \(selectedImageData.count) items away",
                    icon: "lock.fill",
                    action: onContinue
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer().frame(height: 16)
        }
        .padding(.horizontal, Theme.padding)
        .overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(Theme.accent)
                        Text("Loading photos...")
                            .font(Theme.callout)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .card()
                }
            }
        }
        .onChange(of: selectedPhotos) { _, items in
            Task { await loadPhotos(items) }
        }
    }

    private func loadPhotos(_ items: [PhotosPickerItem]) async {
        isLoading = true
        var results: [(Data, String?)] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                results.append((data, nil))
            }
        }
        await MainActor.run {
            selectedImageData = results
            isLoading = false
        }
    }
}
