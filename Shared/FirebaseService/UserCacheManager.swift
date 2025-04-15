//
//  UserCacheManager.swift
//  Forum
//
//  Created by Cem Beyenal on 2/6/25.
//

import FirebaseFirestore

class UserCacheManager {
    static let shared = UserCacheManager() // ✅ Singleton instance

    private var userCache: [String: String] = [:] // ✅ Stores userId → name mapping
    private let db = Firestore.firestore()

    private init() {} // ✅ Prevents external initialization

    // ✅ Fetches the user’s name, either from cache or Firestore
    func getCachedUserName(for userId: String) -> String? {
        return userCache[userId]
    }
    
    func cacheUserName(_ userId: String, name: String) {
        userCache[userId] = name
    }
}
