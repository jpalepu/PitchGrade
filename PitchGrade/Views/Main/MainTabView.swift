import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationView {
                    MainContentView(viewModel: viewModel)
                }
                .tag(0)
                
                NavigationView {
                    UserProfileView()
                }
                .tag(1)
            }
            
            // Custom Floating Tab Bar
            FloatingTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 0 {
                // Reset to home view when home tab is selected
                viewModel.reset()
                viewModel.currentStep = .selectMode
            }
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

struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                TabBarButton(
                    index: index,
                    selectedTab: $selectedTab,
                    colorScheme: colorScheme
                )
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(.regularMaterial)
                .opacity(colorScheme == .dark ? 0.7 : 0.9)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
        .frame(width: min(UIScreen.main.bounds.width - 64, 300), height: 50)
    }
}

struct TabBarButton: View {
    let index: Int
    @Binding var selectedTab: Int
    let colorScheme: ColorScheme
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: getIcon(for: index))
                    .font(.system(size: 18))
                
                Text(getTitle(for: index))
                    .font(.caption2)
            }
            .foregroundColor(selectedTab == index ? .primary : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                selectedTab == index ?
                Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.1) :
                Color.clear
            )
            .clipShape(Capsule())
        }
    }
    
    private func getIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "clock.fill"
        case 2: return "person.fill"
        default: return ""
        }
    }
    
    private func getTitle(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "History"
        case 2: return "Profile"
        default: return ""
        }
    }
}

struct UserProfileView: View {
    var body: some View {
        ZStack {
            // Same gradient background as HomeView for consistency
            LinearGradient(
                colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Text("User Profile")
                .font(.title)
                .foregroundColor(.white)
        }
        .navigationTitle("Profile")
    }
} 
