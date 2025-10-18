import SwiftUI
import Combine

class DetailViewModel: ObservableObject {
    @Published var item: HistoryItem
    
    private let persistence = PersistenceController.shared
    private let networkService = NetworkService()
    private var cancellables = Set<AnyCancellable>()
    
    init(item: HistoryItem) {
        self.item = item
        
        if case let .barcode(productInfo) = item.codeType,
           productInfo == nil {
            networkService.fetchProductInfo(barcode: item.content)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { value in }) { info in
                    self.item.codeType = .barcode(info)
                }
                .store(in: &cancellables)
        }
    }
    
    func saveNewName(_ name: String) {
        item.title = name
        Task {
            await persistence.save(code: item)
        }
    }
    
 
    
}

