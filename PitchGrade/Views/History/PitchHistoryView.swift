import SwiftUI

struct PitchHistoryView: View {
    @State private var searchText = ""
    @EnvironmentObject private var viewModel: PitchViewModel
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search pitches...", text: $searchText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // History list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.savedPitches) { pitch in
                            PitchHistoryCard(pitch: pitch)
                        }
                    }
                    .padding()
                }
            }
            .padding(.top)
        }
        .navigationTitle("Pitch History")
    }
}

struct PitchHistoryCard: View {
    let pitch: SavedPitch
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pitch.businessName)
                        .font(.headline)
                    
                    Text(pitch.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(scoreColor)
                        .frame(width: 40, height: 40)
                    
                    Text("\(pitch.score)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Text(pitch.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Image(systemName: pitch.mode == .camera ? "doc.text.fill" : "waveform")
                    .foregroundColor(.blue)
                
                Text(pitch.mode == .camera ? "Document" : "Voice")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Button {
                    // View details action
                } label: {
                    Text("View Details")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
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
