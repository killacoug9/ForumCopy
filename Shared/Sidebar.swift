//
//  Sidebar.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 12/30/23.
//

import Foundation
import SwiftUI

struct Sidebar: View {
    let width: CGFloat
    let authService = AuthService.shared
    
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @Binding var showSidebar: Bool
    @Binding var sidebarActive: Bool
    @Binding var sidebarOffset: CGFloat
    @State private var isAccountPagePresented = false

    var body: some View {
        VStack(alignment: .leading) {
            // Sidebar Content
            
            Spacer()
            
            // Account button
            Button(action: {
                isAccountPagePresented = true // Show the Profile page modal
            }) {
                HStack {
                    Text("Account")
                        .font(.title2)
                        .foregroundColor(.black)

                    Image(systemName: "person.fill")
                        .foregroundColor(.black)
                }
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Logout Button
            Button(action: {
                authService.logout {
                    withAnimation {
                        showSidebar = false
                        sidebarOffset = 0 // Reset sidebar position
                        sidebarActive = false
                    }
                }
                print("Successfully logged out!")
            }) {
                HStack {
                    Text("Logout")
                        .font(.title2)
                        .foregroundColor(.red)

                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.leading, 20)
        .frame(width: width)
        .overlay(
            Rectangle()
                .frame(width: 0.75)
                .foregroundColor(.black),
            alignment: .trailing
        )
        .background(Color("Sea"))
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $isAccountPagePresented) {
            AccountSettingsView() // Present the ProfilePageView as a popup sheet
        }
    }
}
