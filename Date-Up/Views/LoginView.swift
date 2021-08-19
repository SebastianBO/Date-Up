//
//  LoginView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    private let textFieldColor = Color("TextFieldsColor")
    @State private var switchToRegisterView = false
    @ObservedObject var sessionStore = SessionStore()
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if switchToRegisterView {
                withAnimation {
                    RegisterView()
                }
            } else {
                VStack (spacing: screenHeight * -0.4) {
                    TopView()
                        .frame(width: screenWidth, height: screenHeight)
                
                    VStack {
                        Group {
                            TextField("e-mail", text: $email)
                            
                            SecureField("password", text: $password)
                        }
                        .padding()
                        .background(textFieldColor)
                        .cornerRadius(5.0)
                        .padding(.bottom, screenHeight * 0.02)
                        
                        Spacer()
                        
                        VStack {
                            Button(action: {
                                withAnimation {
                                    sessionStore.signIn(email: email, password: password)
                                }
                            }, label: {
                                Text("Login")
                                    .font(.system(size: screenHeight * 0.026))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(minWidth: screenWidth * 0.4, maxHeight: screenHeight * 0.08)
                                    .background(Color.green)
                                    .cornerRadius(15.0)
                            })
                            
                            Button(action: {
                                withAnimation {
                                    switchToRegisterView.toggle()
                                }
                            }, label: {
                                Text("Register")
                                    .font(.system(size: screenHeight * 0.026))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: screenWidth * 0.4, height: screenHeight * 0.08)
                                    .background(Color.green)
                                    .cornerRadius(15.0)
                            })
                        }
                        
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .frame(width: screenWidth)
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
