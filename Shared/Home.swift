import SwiftUI
import CoreLocation

struct Home: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var address: String = "Fetching address..."
    @State private var showSidebar = false
    @State private var sidebarOffset: CGFloat = 0
    @State private var sidebarActive = true;
    @State private var url = "Home"
    
    // Below 2 lines are  code added for Posts on 9/23/24
    @State private var posts: [Post] = [] // Array to store posts
    @State private var postContent: String = "" // For post input
    @State private var showPostView: Bool = false // For showing the post input view
    
    // For Bottom bar opacity when scrolling
    @State private var isButtonTransparent: Bool = true // New property
    
    // keeps track if user is logged in on device
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    
    private var sidebarWidth: CGFloat = 300
    
    var body: some View {
        let background = colorScheme == .dark ? Color("BlackDarkMode") : Color("Cream")
        let screenWidth = UIScreen.main.bounds.width
        let dragStartZone = screenWidth * 0.1
        
        let drag = DragGesture()
            .onChanged { value in
                if value.startLocation.x < dragStartZone && value.translation.width > 0 { // Drag Right
                    if(sidebarOffset >= sidebarWidth) {
                        return
                    }
                    if(value.translation.width < sidebarWidth) {
                        sidebarOffset = value.translation.width
                    } else {
                        sidebarOffset = sidebarWidth
                    }
                } else { // Drag Left
                    if(sidebarOffset == 0) {
                        return
                    }
                    if(value.translation.width > -sidebarWidth) {
                        sidebarOffset = sidebarWidth + value.translation.width
                    } else {
                        sidebarOffset = 0
                    }
                }
            }
            .onEnded { value in
                if value.startLocation.x < dragStartZone && value.translation.width > 150 {
                    let speed = abs(value.velocity.width)
                    let response = max(0.1, min(0.5, 2000 / speed))
                    
                    withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.5, blendDuration: 0)) {
                        sidebarOffset = sidebarWidth
                    }
                } else {
                    let speed = abs(value.velocity.width)
                    let response = max(0.1, min(0.5, 2.0 / speed))
                    let damping = max(0.5, min(0.9, speed / 1000))
                    
                    withAnimation(.interactiveSpring(response: response, dampingFraction: damping, blendDuration: 0)) {
                        sidebarOffset = 0
                        showSidebar = true
                    }
                }
            }
        
        ZStack {
            // Check if user is logged in using @AppStorage
            if !isLoggedIn {
                // Display the login view if the user is not logged in
                LoginView()
            } else {
                // Main app content when logged in
                Sidebar(width: sidebarWidth, showSidebar: $showSidebar, sidebarActive: $sidebarActive, sidebarOffset: $sidebarOffset)
                    .offset(x: -300 + sidebarOffset)
                    .zIndex(1) // Ensure sidebar is underneath main content
                    .padding(.trailing, screenWidth-300)
                
                ZStack(alignment: .top) {
                    if(url == "Home") {
                        Places(isButtonTransparent: $isButtonTransparent, posts: $posts) // Pass currentLocationCategory to Places
                            .onAppear {
                                self.sidebarActive = true
                            }
                            .onDisappear {
                                if(self.url == "Home") {
                                    self.sidebarActive = false
                                }
                            }
                    } else if(url == "Representatives") {
                        RepresentativesView(sidebarOffset: $sidebarOffset, sidebarActive: $sidebarActive, url: $url, isButtonTransparent: $isButtonTransparent)
                    } else if(url == "Companies") {
                        Companies()
                            .onAppear {
                                self.sidebarActive = true
                            }
                            .onDisappear {
                                if(self.url == "Companies") {
                                    self.sidebarActive = false
                                }
                            }
                    }
                    
                    BottomBar(url: $url, isButtonTransparent: $isButtonTransparent)
                        .opacity(isButtonTransparent ? 0.3 : 1.0) // Change opacity only when scrolling down
                        .animation(.easeInOut, value: isButtonTransparent)
                    Spacer()
                }//ZStack
                .offset(x: sidebarOffset)
                .background(background)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    Group {
                        if sidebarOffset == sidebarWidth {
                            Color.black.opacity(0.001)
                                .onTapGesture {
                                    withAnimation {
                                        sidebarOffset = 0
                                    }
                                }
                        }
                    }
                )
            }
        } // overlay for swiping right to access sidebar over the tabview in places
        .overlay(
            Group {
                if sidebarActive {
                    Color.clear
                        .frame(width: 50) // active area on left edge for swiping for sidebar
                        .contentShape(Rectangle())
                        .highPriorityGesture(drag)
                }
            },
            alignment: .leading
        )
        .gesture(sidebarActive ? drag : nil)
        
        // puts the sidebar back after logging out
        .onChange(of: isLoggedIn) { newValue in
              if !newValue {
                  withAnimation {
                      showSidebar = false
                      sidebarOffset = 0
                  }
              }
          }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
