//
//  TwitterCloneView.swift
//  Forum (iOS)
//
//  Created by Aaron De Guzman on 2/29/24.
//

import Foundation
import SwiftUI

struct TwitterCloneView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Tweets")) {
                    ForEach(0..<10) {index in
                        TweetRowView()
                    }
                }
                Section(header: Text("Trending Hashtags")) {
                    ForEach(0..<10) {index in
                        HashtagRowView()
                    }
                }
            }
            .navigationBarTitle(Text("Twitter Clone"))
        }
    }
}

struct TweetRowView: View {
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text("User Name")
                    .font(.headline)
                Text("@username")
                    .font(.subheadline)
                Text("This is a tweet. #hashtag")
            }
            Spacer()
            Image(systemName: "ellipsis")
        }
    }
}

struct HashtagRowView: View {
    var body: some View {
        HStack {
            Text("#hashtag")
                .font(.headline)
            Spacer()
            Text("100K Tweets")
        }
    }
}
