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
    @State private var sendRecoveryEmailButtonPressed = false
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
                                Section(footer: Text("Forgot Password?").foregroundColor(.blue).onTapGesture {
                                    showForgotPasswordSheet = true
                                }) {
                                    TextField("E-mail", text: $email)
                                    
                                    SecureField("Password", text: $password)
                                }
                            }
                            .frame(width: screenWidth, height: screenHeight * 0.8)
                            .sheet(isPresented: $showForgotPasswordSheet, content: {
                                NavigationView {
                                    ScrollView(.vertical) {
                                        Form {
                                            Section(header: Text("Forgot Password"), footer: sendRecoveryEmailButtonPressed ? (recoveryEmailSent ? Text("Recovery e-mail has been sent! Please check your inbox.").foregroundColor(.green) : Text("Please provide correct e-mail address").foregroundColor(.red)) : Text("Please provide your e-mail address so that we could send you recovery e-mail with instructions to reset the password.")) {
                                                TextField("E-mail", text: $forgotPasswordEmail)
                                            }
                                        }
                                        .frame(width: screenWidth, height: screenHeight * 0.87)
                                        
                                        HStack {
                                            Button(action: {
                                                withAnimation {
                                                    sendRecoveryEmailButtonPressed = true
                                                    if checkEmail() {
                                                        sessionStore.sendRecoveryEmail(forgotPasswordEmail)
                                                        recoveryEmailSent = true
                                                    }
                                                }
                                            }, label: {
                                                Text("Send Recovery E-mail")
                                                    .font(.system(size: screenHeight * 0.026))
                                                    .foregroundColor(.white)
                                            })
                                            .frame(width: screenWidth * 0.6, height: screenHeight * 0.07)
                                            .background(Color.green)
                                            .cornerRadius(15.0)
                                        }
                                        .frame(width: screenWidth * 0.6, height: screenHeight * 0.07)
                                    }
                                    .navigationBarTitle("Forgot Password Form", displayMode: .inline)
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
                            .frame(width: screenWidth, height: screenHeight * 0.05)
                            .font(.system(size: screenHeight * 0.026))
                                        .foregroundColor(.white)
                                        .padding()
                        }
                        .navigationBarTitle("Login Form", displayMode: .inline)
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private func checkEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: forgotPasswordEmail)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
             LoginView().preferredColorScheme($0)
        }
    }
}
