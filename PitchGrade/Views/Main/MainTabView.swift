import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case 0:
                    NavigationView {
                        MainContentView(viewModel: viewModel)
                    }
                case 1:
                    NavigationView {
                        PitchHistoryView()
                    }
                case 2:
                    NavigationView {
                        UserProfileView()
                            .environmentObject(authViewModel)
                            .environmentObject(viewModel)
                    }
                default:
                    EmptyView()
                }
            }
            
            // Floating Tab Bar
            HStack(spacing: 0) {
                ForEach(0..<3) { index in
                    TabBarButton(
                        index: index,
                        selectedTab: $selectedTab,
                        title: getTabTitle(index),
                        icon: getTabIcon(index)
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8) // Made smaller
            .background(
                Capsule()
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
    
    private func getTabTitle(_ index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "History"
        case 2: return "Profile"
        default: return ""
        }
    }
    
    private func getTabIcon(_ index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "clock.fill"
        case 2: return "person.fill"
        default: return ""
        }
    }
}

struct MainContentView: View {
    @ObservedObject var viewModel: PitchViewModel
    
    var body: some View {
        Group {
            switch viewModel.currentStep {
            case .selectMode:
                HomeView()
                    .environmentObject(viewModel)
            case .questionnaire:
                QuestionnaireView()
            case .confirmIdea:
                IdeaConfirmationView()
            case .summaryReview:
                if let summary = viewModel.generatedSummary {
                    PitchSummaryReviewView(summary: summary)
                } else {
                    ProgressView("Generating summary...")
                }
            case .selectDuration:
                PitchDurationView()
            case .selectStyle:
                PitchStyleView()
            case .capture:
                if viewModel.selectedMode == .camera {
                    CameraCaptureView()
                } else {
                    VoiceRecordingView()
                }
            case .analysis:
                AnalysisReportView()
            }
        }
    }
}

struct UserProfileView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var viewModel: PitchViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // User Avatar
                        Circle()
                            .fill(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .padding(20)
                            )
                        
                        // User Info
                        VStack(spacing: 8) {
                            if let email = authViewModel.user?.email {
                                Text(email)
                                    .font(.headline)
                            }
                            
                            if let creationDate = authViewModel.user?.metadata.creationDate {
                                Text("Member since \(creationDate.formatted(.dateTime.month().year()))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // Stats Section
                    VStack(spacing: 16) {
                        Text("Your Stats")
                            .font(.headline)
                        
                        HStack(spacing: 30) {
                            StatView(title: "Pitches", value: "\(viewModel.savedPitches.count)")
                            StatView(title: "Avg Score", value: averageScore)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 8)
                    
                    // Sign Out Button
                    Button(action: {
                        authViewModel.signOut()
                        viewModel.currentStep = .selectMode
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var averageScore: String {
        guard !viewModel.savedPitches.isEmpty else { return "N/A" }
        let total = viewModel.savedPitches.reduce(0) { $0 + $1.score }
        let average = Double(total) / Double(viewModel.savedPitches.count)
        return String(format: "%.1f", average)
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 100)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TabBarButton: View {
    let index: Int
    @Binding var selectedTab: Int
    let title: String
    let icon: String
    
    var body: some View {
        Button {
            withAnimation(.spring()) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(selectedTab == index ? .accentColor : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
    }
} 
