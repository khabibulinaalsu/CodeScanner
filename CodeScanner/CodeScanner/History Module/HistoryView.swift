import SwiftUI

struct HistoryView: View {
    
    @StateObject var viewModel = HistoryViewModel()
    
    var body: some View {
        ForEach(viewModel.history) { item in
            NavigationLink {
                DetailView(viewModel: DetailViewModel(item: item), title: item.title)
            } label: {
                HistoryRowView(item: item)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadHistory()
            }
        }
    }
}

struct HistoryRowView: View {
    
    var item: HistoryItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.codeType.iconName)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text(item.codeType.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(item.timestamp.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}
