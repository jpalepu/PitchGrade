import SwiftUI

struct LandingPagesView: View {
    @State private var currentPage = 0
    @EnvironmentObject private var viewModel: PitchViewModel
    @State private var isAnimating = false
    
    let pages = [
        LandingPage(
            title: "Welcome to\nPitchGrade",
            subtitle: "Your AI-Powered Pitch Coach",
            description: "Transform your startup pitch from good to exceptional with advanced AI analysis",
            imageName: "wand.and.stars.inverse",
            gradientColors: [Color(hex: "08AEEA"), Color(hex: "2AF598")]
        ),
        LandingPage(
            title: "Intelligent\nAnalysis",
            subtitle: "Powered by Advanced AI",
            description: "Get detailed feedback on your pitch with actionable insights and step-by-step improvements",
            imageName: "brain.head.profile",
            gradientColors: [Color(hex: "FF3CAC"), Color(hex: "784BA0"), Color(hex: "2B86C5")]
        ),
        LandingPage(
            title: "Start Your\nJourney",
            subtitle: "Elevate Your Pitch",
            description: "Join thousands of entrepreneurs in crafting the perfect pitch for your startup",
            imageName: "rocket.fill",
            gradientColors: [Color(hex: "21D4FD"), Color(hex: "B721FF")]
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        LandingPageView(page: pages[index], screenSize: geometry.size)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                .ignoresSafeArea()
                
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
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(.white.opacity(0.2))
                                    )
                            }
                            .padding(.trailing, 20)
                            .padding(.top, geometry.safeAreaInsets.top + 10)
                        }
                    }
                    
                    Spacer()
                    
                    // Page Controls
                    VStack(spacing: 30) {
                        // Custom Page Indicator
                        HStack(spacing: 12) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Capsule()
                                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.5))
                                    .frame(width: currentPage == index ? 24 : 8, height: 8)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Get Started Button
                        if currentPage == pages.count - 1 {
                            Button {
                                withAnimation(.spring()) {
                                    viewModel.completeOnboarding()
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Text("Get Started")
                                        .font(.title3.bold())
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.title3)
                                        .offset(x: isAnimating ? 5 : 0)
                                        .animation(
                                            .easeInOut(duration: 0.8)
                                            .repeatForever(autoreverses: true),
                                            value: isAnimating
                                        )
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.white.opacity(0.2), .white.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .clipShape(Capsule())
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(LinearGradient(
                                            colors: [.white.opacity(0.4), .white.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal, 40)
                            .scaleEffect(isAnimating ? 1.02 : 1)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                        }
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct LandingPageView: View {
    let page: LandingPage
    let screenSize: CGSize
    @State private var isAnimating = false
    @State private var showElements = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: page.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated background elements
            GeometryReader { geo in
                ZStack {
                    // Background circles
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: geo.size.width * CGFloat(0.5 + Double(index) * 0.2))
                            .offset(
                                x: isAnimating ? geo.size.width * 0.2 : -geo.size.width * 0.2,
                                y: isAnimating ? geo.size.height * 0.1 : -geo.size.height * 0.1
                            )
                            .blur(radius: 30)
                            .animation(
                                .easeInOut(duration: Double(4 + index))
                                .repeatForever(autoreverses: true)
                                .delay(Double(index)),
                                value: isAnimating
                            )
                    }
                }
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Icon with glowing effect
                ZStack {
                    ForEach(0..<2) { i in
                        Image(systemName: page.imageName)
                            .font(.system(size: 100))
                            .foregroundColor(.white.opacity(i == 0 ? 0.3 : 1))
                            .blur(radius: i == 0 ? 10 : 0)
                            .scaleEffect(isAnimating ? 1 + CGFloat(i) * 0.1 : 0.8)
                            .offset(y: showElements ? 0 : 50)
                            .animation(
                                .spring(response: 0.8, dampingFraction: 0.6)
                                .delay(0.1),
                                value: showElements
                            )
                    }
                }
                .symbolEffect(.bounce, options: .repeating)
                
                // Text content
                VStack(spacing: 25) {
                    Text(page.title)
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .offset(x: showElements ? 0 : -50)
                        .opacity(showElements ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: showElements)
                    
                    Text(page.subtitle)
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                        .offset(x: showElements ? 0 : 50)
                        .opacity(showElements ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3), value: showElements)
                    
                    Text(page.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 32)
                        .offset(y: showElements ? 0 : 50)
                        .opacity(showElements ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4), value: showElements)
                }
                
                Spacer()
                Spacer()
            }
            .padding(.top, screenSize.height * 0.1)
        }
        .onAppear {
            isAnimating = true
            withAnimation(.easeOut(duration: 0.8)) {
                showElements = true
            }
        }
    }
}

struct LandingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let gradientColors: [Color]
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