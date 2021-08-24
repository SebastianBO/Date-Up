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
                VStack(spacing: screenHeight * -0.89) {
                    TopView()
                        .frame(width: screenWidth, height: screenHeight)
                
                    NavigationView {
                        VStack {
                            Form {
                                Section {
                                    TextField("E-mail", text: $email)
                                    
                                    SecureField("Password", text: $password)
                                }
                            }
                                
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
                        .ignoresSafeArea(.keyboard)
                        .frame(width: screenWidth, height: screenHeight * 0.83)
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
