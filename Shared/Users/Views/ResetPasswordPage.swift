//
//  ResetPasswordPage.swift
//  Forum (iOS)
//
//  Created by Sierra Pine on 3/1/25.
//

import SwiftUI

struct ResetPasswordPage: View {
    
    @State var email: String = ""
    @State private var isResetEmailSent: Bool = false
    
    let authService = AuthService.shared
    
    var body: some View {
        
        ZStack {
            // background color
            Color("Cream")
                .edgesIgnoringSafeArea(.all)
            
            if isResetEmailSent {
                // Show confirmation message after email is sent
                Text("A password reset email has been sent to \(email).")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .padding()
                    .multilineTextAlignment(.center)
            } else {
                VStack(alignment: .leading) {
                    
                    Text("Reset Password ")
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
                    
                    // reset button
                    Button(action: {
                        authService.resetPassword(email: email)
                        isResetEmailSent = true
                    }) {
                        Text("Send Reset Email")
                            .font(.system(size: 20))
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Watermelon"))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    }
                    .padding(.horizontal, 80)
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    ResetPasswordPage()
}
