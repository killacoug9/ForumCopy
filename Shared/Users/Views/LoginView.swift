//
//  Login.swift
//  Forum (iOS)
//
//  Created by Sierra Pine on 1/29/25.
//

import SwiftUI
import Firebase

struct LoginView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    
    let authService = AuthService.shared
    
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var showSignUp = false
    @State var showPassword: Bool = false
    @State private var showPasswordResetPage = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // background color
                Color("Cream")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Forum")
                        .bold()
                        .padding(.top, 60)
                        .font(.system(size: 44))
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Image("Forum")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    
                    
                    
                    // Email Field
                    VStack(alignment: .leading) {
                        
                        // login
                        Text("Login Here: ")
                            .bold()
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                            .font(.system(size: 35))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Text("Email:")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        TextField("", text: $email)
                            .textContentType(.emailAddress)
                            .padding()
                            .autocapitalization(.none)
                            .frame(height: 40)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        
                        Text("Password:")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        
                        // show password
                        HStack {
                            ZStack(alignment: .trailing) {
                                if showPassword {
                                    TextField("", text: $password)
                                        .textContentType(.password)
                                        .autocapitalization(.none)
                                        .padding()
                                } else {
                                    SecureField("", text: $password)
                                        .textContentType(.password)
                                        .autocapitalization(.none)
                                        .padding()
                                }
                                
                                // show password button
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 10)
                            }
                            .frame(height: 40)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        }
                        
                        // forget password button
                        HStack {
                            Spacer()
                            Button(action: {
                                showPasswordResetPage = true
                            }) {
                                Text("Forgot Password?")
                                    .padding(.trailing, 10)
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                            }
                        }
                    
                        
                       
                        
                    }
                    .padding(.horizontal, 20)
                    
                    
                    // Login Button
                    Button(action: {
                        authService.loginUser(email: email, password: password) { success, error in
                            if success {
                                isLoggedIn = true
                            }
                        }
                        // print("Successfully logged in!")
                    }) {
                        Text("Login")
                            .font(.system(size: 20))
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Watermelon"))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("Watermelon"), lineWidth: 1))
                    }
                    .padding(.horizontal, 80)
                    
                    // shows errors when logging in ********* NEEDS FIXING **********
                    if let errorMessage = authService.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                        
                        Button(action: {
                            showSignUp = true // Show SignUpView
                        }) {
                            Text("Sign up here")
                                .font(.system(size: 20))
                                .foregroundColor(.blue) // Make it look like a link
                        }

                    }
                    
                }
                
                .fullScreenCover(isPresented: $showSignUp) {
                    SignUpView()
                }
            }
        }
        // shows the reset password page
        .sheet(isPresented: $showPasswordResetPage) {
            ResetPasswordPage()
        }
    }
    
}


struct Login_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
    
}
