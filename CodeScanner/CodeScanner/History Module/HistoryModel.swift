import Foundation

typealias HistoryModel = [HistoryItem]

struct HistoryItem: Identifiable {
    let id: UUID
    var title: String
    let content: String
    var codeType: CodeType
    let timestamp: Date
}

