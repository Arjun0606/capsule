import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID = UUID()
    var date: Date = Date()
    var body: String = ""
    var prompt: String?
    var vault: Vault?

    init(body: String, prompt: String? = nil) {
        self.id = UUID()
        self.date = .now
        self.body = body
        self.prompt = prompt
    }
}
