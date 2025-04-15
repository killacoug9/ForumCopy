//
//  AddPostButton.swift
//  Forum
//
//  Created by Cem Beyenal on 10/8/24.
//


import SwiftUI

struct AddPostButton: View {
    @Binding var showPostView: Bool
    @Binding var posts: [Post]
    @Binding var locationCategory: LocationCategory

    var body: some View {
        VStack {
            Spacer() // Push the button to the bottom of the view
            HStack {
                Spacer() // Push the button to the right
                Button(action: {
                    print("Add post tapped!")
                    showPostView.toggle() // Show the post input view
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20) // Size of the button
                        .padding()
                        .background(Color.white) // Background color of the button
                        .foregroundColor(Color("Sea")) // Color of the plus icon
                        .clipShape(Circle()) // Makes the button circular
                        .shadow(radius: 5) // Optional shadow for effect
                }
                .padding(.trailing, 10)
                .padding(.bottom, 80)
            }
        }
        .edgesIgnoringSafeArea(.all) // Ignore safe area for bottom-right placement
    }
}
