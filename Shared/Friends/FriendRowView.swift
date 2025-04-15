//
//  FriendRowView.swift
//  Forum
//
//  Created by Cem Beyenal on 3/30/25.
//

import SwiftUI

struct FriendRowView: View {
    let friend: UserInfo

    var body: some View {
        HStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(Text(friend.firstName.prefix(1)).font(.headline))
//            Image(systemName: "person.circle.fill")
//                .resizable()
//                .frame(width: 40, height: 40)
//                .foregroundColor(.gray)
//                .padding(.leading, 5)
            
            VStack(alignment: .leading) {
                Text("\(friend.firstName) \(friend.lastName)").font(.headline)
                Text(friend.email).font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}
