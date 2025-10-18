import SwiftUI

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    HistoryView()
                }
                NavigationLink {
                    ScannerView()
                    
                } label: {
                    Text("Отсканировать код")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.blue)
                        .cornerRadius(12)
                        .foregroundStyle(.background)
                }
                .padding(.bottom, 54)
            }
            .navigationTitle("История")
        }
    }
    
}
