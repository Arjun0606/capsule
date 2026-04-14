import Foundation
import Photos
import UIKit

@Observable
final class PhotoService {

    var authorizationStatus: PHAuthorizationStatus = .notDetermined

    func requestAccess() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run { authorizationStatus = status }
        return status == .authorized || status == .limited
    }

    // MARK: - Fetch image data from PHAsset

    func fetchImageData(for asset: PHAsset) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat

            PHImageManager.default().requestImageDataAndOrientation(
                for: asset, options: options
            ) { data, _, _, info in
                if let data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: PhotoError.fetchFailed)
                }
            }
        }
    }

    // MARK: - Fetch thumbnail

    func fetchThumbnail(for asset: PHAsset, size: CGSize = CGSize(width: 200, height: 200)) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                if let image, let data = image.jpegData(compressionQuality: 0.7) {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: PhotoError.fetchFailed)
                }
            }
        }
    }

    // MARK: - Delete from photo library

    func deleteAssets(_ identifiers: [String]) async throws {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets)
        }
    }

    // MARK: - Restore to photo library

    func restoreImage(data: Data) async throws -> String {
        var localID = ""
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAsset(from: UIImage(data: data) ?? UIImage())
            localID = request.placeholderForCreatedAsset?.localIdentifier ?? ""
        }
        return localID
    }
}

enum PhotoError: LocalizedError {
    case fetchFailed
    case deleteFailed
    case restoreFailed

    var errorDescription: String? {
        switch self {
        case .fetchFailed:  "Could not load photo."
        case .deleteFailed: "Could not remove photo from library."
        case .restoreFailed: "Could not restore photo to library."
        }
    }
}
