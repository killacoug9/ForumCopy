import SwiftUI

struct MenuButton: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        print("Button tapped")
                    }) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 140, height: 140)
                    }.offset(x: 62, y: 85)
                }
            }
        }
    }
}

@main
struct ForumApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            Home()
//                .modifier(MenuButton())
        }
    }
}
