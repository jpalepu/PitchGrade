import SwiftUI

struct LandingPagesView: View {
    @State private var currentPage = 0
    @EnvironmentObject private var viewModel: PitchViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showingAuth = false
    @State private var authMode: AuthenticationView.Mode = .signIn
    
    let pages = [
        LandingPage(
            title: "PitchGrade",
            subtitle: "Perfect Your Pitch",
            description: "Transform your startup pitch with AI-powered analysis and feedback",
            content: AnyView(
                WaveformAnimation()
                    .scaleEffect(1.2)
                    .blur(radius: 0.5)
            ),
            accentColor: .blue
        ),
        LandingPage(
            title: "Smart Analysis",
            subtitle: "Detailed Insights",
            description: "Get personalized feedback on your delivery, structure, and presentation style",
            content: AnyView(
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 80))
                    .foregroundColor(.indigo)
            ),
            accentColor: .indigo
        ),
        LandingPage(
            title: "Ready to Start?",
            subtitle: "Join PitchGrade",
            description: "Create an account or sign in to begin your journey",
            content: AnyView(
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(.purple)
            ),
            accentColor: .purple
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        LandingPageView(page: pages[index])
                            .tag(index)
                    }
                    
                    // Last page with auth buttons
                    if currentPage == pages.count - 1 {
                        VStack(spacing: 16) {
                            Button {
                                authMode = .signUp
                                showingAuth = true
                            } label: {
                                Text("Get Started")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: min(geometry.size.width - 80, 300))
                                    .padding(.vertical, 16)
                                    .background(pages[currentPage].accentColor)
                                    .cornerRadius(16)
                            }
                            
                            Button {
                                authMode = .signIn
                                showingAuth = true
                            } label: {
                                Text("Already have an account? Sign In")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Overlay controls
                VStack {
                    // Skip button
                    if currentPage < pages.count - 1 {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation(.spring()) {
                                    viewModel.completeOnboarding()
                                }
                            } label: {
                                Text("Skip")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.trailing, 32)
                            .padding(.top, geometry.safeAreaInsets.top + 16)
                        }
                    }
                    
                    Spacer()
                    
                    // Page Controls
                    VStack(spacing: 32) {
                        // Custom Page Indicator
                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Capsule()
                                    .fill(currentPage == index ? pages[index].accentColor : .gray.opacity(0.2))
                                    .frame(width: currentPage == index ? 16 : 4, height: 4)
                                    .animation(.spring(response: 0.3), value: currentPage)
                            }
                        }
                        
                        // Auth Buttons
                        if currentPage == pages.count - 1 {
                            VStack(spacing: 16) {
                                Button {
                                    authMode = .signUp
                                    showingAuth = true
                                } label: {
                                    Text("Get Started")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: min(geometry.size.width - 80, 300))
                                        .padding(.vertical, 16)
                                        .background(pages[currentPage].accentColor)
                                        .cornerRadius(16)
                                }
                                
                                Button {
                                    authMode = .signIn
                                    showingAuth = true
                                } label: {
                                    Text("Already have an account? Sign In")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 50)
                }
            }
        }
        .sheet(isPresented: $showingAuth) {
            AuthenticationView(mode: authMode)
                .environmentObject(authViewModel)
        }
    }
}

struct LandingPageView: View {
    let page: LandingPage
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 48) {
            // Content
            page.content
                .padding(.top, 100)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(page.subtitle)
                    .font(.title3)
                    .foregroundColor(page.accentColor)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

struct LandingPage {
    let title: String
    let subtitle: String
    let description: String
    let content: AnyView
    let accentColor: Color
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 