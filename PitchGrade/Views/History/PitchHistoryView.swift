import SwiftUI

struct PitchHistoryView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.savedPitches) { pitch in
                    PitchHistoryCard(pitch: pitch)
                }
            }
            .padding()
        }
        .navigationTitle("History")
        .background(Color(.systemGroupedBackground))
    }
}

struct PitchHistoryCard: View {
    let pitch: SavedPitch
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(pitch.businessName)
                .font(.headline)
            
            Text(pitch.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(pitch.date.formatted(.dateTime.month().day()))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Score: \(pitch.score)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(scoreColor.opacity(0.2))
                    .foregroundColor(scoreColor)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
    
    private var scoreColor: Color {
        switch pitch.score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}
