import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingPageView(
                image: "pitch.document",
                title: "Analyze Your Pitch",
                description: "Get professional feedback on your startup pitch using advanced AI"
            )
            .tag(0)
            
            OnboardingPageView(
                image: "chart.bar",
                title: "Detailed Insights",
                description: "Receive comprehensive analysis and actionable improvements"
            )
            .tag(1)
            
            AuthenticationView()
                .tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct OnboardingPageView: View {
    let image: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.accentColor)
            
            Text(title)
                .font(.title)
                .bold()
            
            Text(description)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
} 