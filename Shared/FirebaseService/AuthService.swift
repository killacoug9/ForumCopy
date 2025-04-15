//
//  AuthService.swift
//  Forum
//
//  Created by Kyle Hawkins on 2/9/25.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class AuthService {
    static let shared = AuthService() // Singleton instance
    
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    private init() {} // Private initializer prevents multiple instances

    func signUp(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                print("Firebase Sign-Up Error: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
            } else if let user = result?.user {
                self.isAuthenticated = true
                self.isLoggedIn = true
                print("User created successfully: \(user.uid)")
                
                // Store user in Firestore
                UserService.shared.storeUserInFirestore(uid: user.uid, firstName: firstName, lastName: lastName, email: email)
                    
                // Store user in friends table
                FriendService.shared.storeUserInFriends(uid: user.uid)
                
                completion(true, nil)
            }
        }
    }

    func loginUser(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                switch error.code {
                    case AuthErrorCode.userNotFound.rawValue:
                        self.errorMessage = "No account found with this email."
                    case AuthErrorCode.wrongPassword.rawValue:
                        self.errorMessage = "Incorrect password. Please try again."
                    default:
                        print("Firebase Login Error: \(error.localizedDescription)")
                }
                completion(false, self.errorMessage)
            } else if let user = result?.user {
                self.isAuthenticated = true
                self.isLoggedIn = true
                print("User successfully logged in: \(user.uid)")
                
                // Fetch user data after login
                UserService.shared.fetchUserData(uid: user.uid) { firstName, lastName, email in
                    print("User Data Fetched: \(firstName) \(lastName) \(email)")
                    completion(true, nil)
                }
                
                // completion(true, nil)
            }
        }
    }

    func logout(completion: (() -> Void)? = nil) {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.isLoggedIn = false
            completion?()
        } catch {
            self.errorMessage = error.localizedDescription
            print("Firebase Logout Error: \(error.localizedDescription)")
        }
    }
    
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    // forget password
    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Error sending password reset email: \(error.localizedDescription)")
            } else {
                print("Password reset email sent successfully.")
            }
        }
    }
}
