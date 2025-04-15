//
//  BottomBar.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 4/29/24.
//

import Foundation
import SwiftUI
import UIKit

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct BottomBar: View {
    @Binding var url: String
    @State private var isTapping: Int = 0
    // For changing opacity when scrolling
    @Binding var isButtonTransparent: Bool // New binding for transparency on decorative when scrolling

    var body: some View {
        ZStack() {
           
            Image("BottomDeco") // "example" should be the name of your PDF file in the Assets
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.8)
                .padding(.top, 65)
                .opacity(isButtonTransparent ? 0 : 1.0) // Change opacity to 0  when scrolling down
                .animation(.easeInOut, value: isButtonTransparent)
            
            HStack {
                
                Spacer()
                Image(systemName: "house")
                    .resizable()
                    .foregroundColor(url == "Home" ? Color("MenuSelected") : Color("MenuUnselected"))
                    .frame(width: 23, height: 20)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    self.isTapping = 1
                                }
                            }
                            .onEnded { _ in
                                self.isTapping = 0
                                self.url = "Home"
                            }
                    )
                Spacer()
                Image(systemName: "graduationcap")
                    .foregroundColor(url == "Representatives" ? Color("MenuSelected") : Color("MenuUnselected"))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    self.isTapping = 2
                                }                            }
                            .onEnded { _ in
                                withAnimation {
                                    self.isTapping = 0
                                }
                                self.url = "Representatives"
                            }
                    )
                
                Spacer()
                Image(systemName: "dollarsign.circle")
                    .resizable()
                    .foregroundColor(url == "Companies" ? Color("MenuSelected") : Color("MenuUnselected"))
                    .frame(width: 22, height: 22)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    self.isTapping = 3
                                }
                            }
                            .onEnded { _ in
                                self.isTapping = 0
                                self.url = "Companies"
                            }
                    )
                
                Spacer()
            }
        }
        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 50)
    }
        
}


//            .overlay(
//                Rectangle()
//                    .frame(height: 1)
//                    .foregroundColor(.gray.opacity(0.4)),
//                alignment: .top
//            )
