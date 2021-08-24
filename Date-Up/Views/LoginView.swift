//
//  LoginView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var forgotPasswordEmail = ""
    @State private var password = ""
    private let textFieldColor = Color("TextFieldsColor")
    @State private var switchToRegisterView = false
    @State private var showForgotPasswordSheet = false
    @State private var recoveryEmailSent = false
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
                VStack(spacing: screenHeight * -0.89) {
                    TopView()
                        .frame(width: screenWidth, height: screenHeight)
                
                    NavigationView {
                        VStack {
                            Form {
                                Section(header: Text("Login Form"), footer: Text("Forgot Password?").foregroundColor(.blue).onTapGesture {
                                    showForgotPasswordSheet = true
                                }) {
                                    TextField("E-mail", text: $email)
                                    
                                    SecureField("Password", text: $password)
                                }
                            }
                            .padding(.top, screenHeight * 0.52)
                            .frame(width: screenWidth, height: screenHeight * 0.8)
                            .sheet(isPresented: $showForgotPasswordSheet, content: {
                                NavigationView {
                                    VStack {
                                        Form {
                                            Section(header: Text("Forgot Password"), footer: recoveryEmailSent ? Text("Recovery e-mail has been sent! Please check your inbox.").foregroundColor(.green) : Text("")) {
                                                TextField("E-mail", text: $forgotPasswordEmail)
                                            }
                                        }
                                        
                                        Button(action: {
                                            withAnimation {
                                                sessionStore.sendRecoveryEmail(forgotPasswordEmail)
                                                recoveryEmailSent = true
                                            }
                                        }, label: {
                                            Text("Send Recovery E-mail")
                                        })
                                        .frame(width: screenWidth * 0.6, height: screenHeight * 0.08)
                                        .background(Color.green)
                                        .cornerRadius(15.0)
                                        .font(.system(size: screenHeight * 0.026))
                                                    .foregroundColor(.white)
                                                    .padding()
                                    }
                                    .navigationBarHidden(true)
                                }
                                .ignoresSafeArea(.keyboard)
                            })
                                
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        sessionStore.signIn(email: email, password: password)
                                    }
                                }, label: {
                                    Text("Login")
                                })
                                .frame(width: screenWidth * 0.4, height: screenHeight * 0.08)
                                            .background(Color.green)
                                            .cornerRadius(15.0)
                                
                                Button(action: {
                                    withAnimation {
                                        switchToRegisterView.toggle()
                                    }
                                }, label: {
                                    Text("Register")
                                })
                                .frame(width: screenWidth * 0.4, height: screenHeight * 0.08)
                                            .background(Color.green)
                                            .cornerRadius(15.0)
                            }
                            .font(.system(size: screenHeight * 0.026))
                                        .foregroundColor(.white)
                                        .padding()
                        }
                        .navigationBarHidden(true)
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
             LoginView().preferredColorScheme($0)
        }
    }
}
