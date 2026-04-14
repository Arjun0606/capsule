import Foundation
import SwiftData

enum VaultItemType: String, Codable {
    case photo
    case video
    case screenshot
    case contact
}

@Model
final class VaultItem {
    var id: UUID = UUID()
    var type: String = VaultItemType.photo.rawValue
    var encryptedFileName: String = ""
    var thumbnailFileName: String?
    var originalAssetIdentifier: String?
    var contactName: String?
    var contactPhone: String?
    var dateAdded: Date = Date()
    var vault: Vault?

    var itemType: VaultItemType {
        get { VaultItemType(rawValue: type) ?? .photo }
        set { type = newValue.rawValue }
    }

    init(type: VaultItemType, encryptedFileName: String, originalAssetIdentifier: String? = nil) {
        self.id = UUID()
        self.type = type.rawValue
        self.encryptedFileName = encryptedFileName
        self.originalAssetIdentifier = originalAssetIdentifier
        self.dateAdded = .now
    }

    init(contactName: String, contactPhone: String) {
        self.id = UUID()
        self.type = VaultItemType.contact.rawValue
        self.contactName = contactName
        self.contactPhone = contactPhone
        self.encryptedFileName = ""
        self.dateAdded = .now
    }
}
