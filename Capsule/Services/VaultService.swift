import Foundation
import CryptoKit
import SwiftData
import SwiftUI

@Observable
final class VaultService {

    // MARK: - Encryption

    private var encryptionKey: SymmetricKey {
        if let keyData = KeychainHelper.load(key: "capsule_vault_key") {
            return SymmetricKey(data: keyData)
        }
        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }
        KeychainHelper.save(key: "capsule_vault_key", data: keyData)
        return key
    }

    private var vaultDirectory: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("vault_data", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // MARK: - Encrypt & Store

    func encryptAndStore(data: Data) throws -> String {
        let sealed = try AES.GCM.seal(data, using: encryptionKey)
        guard let combined = sealed.combined else {
            throw VaultError.encryptionFailed
        }
        let fileName = UUID().uuidString + ".vault"
        let fileURL = vaultDirectory.appendingPathComponent(fileName)
        try combined.write(to: fileURL)
        return fileName
    }

    func decrypt(fileName: String) throws -> Data {
        let fileURL = vaultDirectory.appendingPathComponent(fileName)
        let data = try Data(contentsOf: fileURL)
        let box = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(box, using: encryptionKey)
    }

    // MARK: - Incinerate

    func incinerateVault(_ vault: Vault, context: ModelContext) {
        for item in vault.items {
            let fileURL = vaultDirectory.appendingPathComponent(item.encryptedFileName)
            try? FileManager.default.removeItem(at: fileURL)
            if let thumb = item.thumbnailFileName {
                let thumbURL = vaultDirectory.appendingPathComponent(thumb)
                try? FileManager.default.removeItem(at: thumbURL)
            }
        }
        vault.vaultState = .incinerated
        try? context.save()
    }

    // MARK: - Break Lock (24h Cooldown)

    func startCooldown(_ vault: Vault, context: ModelContext) {
        vault.vaultState = .cooldown
        vault.cooldownStartedAt = .now
        vault.streakDays = 0
        vault.lastStreakDate = nil
        let urge = UrgeEvent(outcome: .brokeOpen)
        urge.vault = vault
        context.insert(urge)
        try? context.save()
    }

    // MARK: - Cleanup expired cooldown

    func checkAndUpdateState(_ vault: Vault) {
        if vault.isExpired && vault.vaultState == .locked {
            vault.vaultState = .unlocked
        }
        if vault.vaultState == .cooldown, !vault.isCooldownActive {
            vault.vaultState = .locked
        }
    }

    func deleteEncryptedFile(_ fileName: String) {
        let fileURL = vaultDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
}

// MARK: - Errors

enum VaultError: LocalizedError {
    case encryptionFailed
    case decryptionFailed
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .encryptionFailed: "Failed to encrypt data."
        case .decryptionFailed: "Failed to decrypt data."
        case .fileNotFound: "Vault file not found."
        }
    }
}

// MARK: - Keychain Helper

enum KeychainHelper {
    static func save(key: String, data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        return result as? Data
    }
}
