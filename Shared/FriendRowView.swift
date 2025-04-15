VStack(alignment: .leading) {
    ForEach(friendsList, id: \.uid) { friend in
        FriendRowView(friend: friend)
    }
}
.padding(.top, 10)