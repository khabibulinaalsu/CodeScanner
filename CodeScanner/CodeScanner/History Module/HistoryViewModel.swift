import SwiftUI
import Combine

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var history: HistoryModel = []
    
    private let persistence = PersistenceController.shared
    
    
    var isEmpty: Bool {
        history.isEmpty
    }
    
    init() {
        Task {
            await loadHistory()
        }
    }
    
    func loadHistory() async {
        history = await persistence.fetchCodes()
    }
    
}
