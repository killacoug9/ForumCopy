//
//  NationTitleBar.swift
//  Forum (iOS)
//
//  Created by Sam Russell on 5/1/24.
//

import Foundation
import SwiftUI

struct TitleBar: View {
    var title: String
    @Binding var tabs: [String]
    @Binding var activeTab: String
    @Binding var offset: CGFloat
    
    @State private var activeTabIndex: Int = 0
    @State var lastOffset: CGFloat = 0.0
    @State var tabScales: [CGFloat] = []

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .bold()
                .foregroundColor(Color("MenuSelected"))
                .padding(.top, 50)
                .padding(.leading, 25)
                .padding(.bottom, 10)
                .font(.system(size: 44))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(tabs.indices, id: \.self) { index in
                        let tab = tabs[index]
                        
                        ZStack {
                            
                            ZStack {
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            print(geometry.size.width)
                                        }
                                }
                                
                                Text(tab)
                                    .foregroundColor(activeTabIndex == index ? Color("Text") : Color("Text"))
                            }
                            
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color("Watermelon"))
                                    .scaleEffect(activeTabIndex == index ? 1 : 0)
                                    .frame(width: geometry.size.width + 20, height: 3)
                                    .offset(x: -10)
                                    .onAppear {
                                        print(tabScales.indices, index, activeTabIndex, index == activeTabIndex)
                                        tabScales.append(index == activeTabIndex ? 1.0 : 0.0)
                                    }
                            }

                        }
                    }
                }
                .padding(.leading, 25)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, -8)
            
            Spacer()
            
//            Rectangle()
//                .fill(.gray.opacity(0.4))
//                .frame(maxWidth: .infinity)
//                .frame(height: 1)
//                .padding(.top, -8)
        }
        .frame(maxWidth: .infinity, maxHeight: 150)
        .background(Color("Cream"))
        .padding(.bottom, -15)
        .onChange(of: offset) { newOffset in
//            swipe(newOffset)
        }
        .onChange(of: activeTab) { newValue in // changes at halfway
            activeTabIndex = tabs.firstIndex(of: activeTab)!
            print("active tab changed")
        }
        .onAppear {
            initializeTabScales()
        }
    }
    
    func initializeTabScales() {
       tabScales = Array(repeating: 0.0, count: tabs.count)
       tabScales[activeTabIndex] = 1.0
   }
    
    func swipe(_ value: CGFloat) {
        var usableValue = value
        if(abs(lastOffset - value) > 80 && abs(lastOffset) > 30) { // First swipe doubles the size for no reason
            usableValue = value - UIScreen.main.bounds.width
        } else {
            if(lastOffset == 0.0) {
                self.lastOffset = 1 // soften first value because it is often wrong
                return
            } else {
                self.lastOffset = value
            }
        }
        
        print(usableValue)
        
        if(usableValue < 0) { 
        // Left
            if(!tabScales.indices.contains(activeTabIndex - 1)) {
                return
            }
            
            print("left move")
            tabScales[activeTabIndex - 1] = 1 - abs(usableValue / UIScreen.main.bounds.width)
            tabScales[activeTabIndex] = usableValue / UIScreen.main.bounds.width
        } else if(usableValue > 0) { 
        // Right
            if(!tabScales.indices.contains(activeTabIndex + 1)) {
                return
            }
            print("right move")
            tabScales[activeTabIndex + 1] = 1 - (usableValue / UIScreen.main.bounds.width)
            tabScales[activeTabIndex] = usableValue / UIScreen.main.bounds.width
        } else {
        // End
            activeTabIndex = tabs.firstIndex(of: activeTab)!
            lastOffset = 0.0
            tabScales = Array(repeating: 0.0, count: tabs.count)
            tabScales[activeTabIndex] = 1.0
        }
//        print(usableValue / UIScreen.main.bounds.width)
    }
}


