//
//  StartView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import SwiftUI

struct StartView: View {
    @State private var switchToLoginView = false
    @State private var switchToRegisterView = false
    @State private var hideButtons = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if switchToRegisterView {
                RegisterView()
            } else {
                VStack (spacing: screenHeight * -0.3) {
                    TopView()
                        .frame(width: screenWidth, height: screenHeight)
                    
                    VStack (spacing: screenHeight * 0.03) {
                        if !hideButtons {
                            Button(action: {
                                withAnimation {
                                    hideButtons.toggle()
                                    switchToLoginView.toggle()
                                }
                            }, label: {
                                Text("Login")
                                    .font(.system(size: screenHeight * 0.026))
                                                .foregroundColor(.white)
                                                .padding()
                                    .frame(width: screenWidth * 0.4, height: screenHeight * 0.08)
                                                .background(Color.green)
                                                .cornerRadius(15.0)
                            })
                            
                            Button(action: {
                                switchToRegisterView.toggle()
                            }, label: {
                                Text("Register")
                                                .font(.system(size: screenHeight * 0.026))
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(width: screenWidth * 0.4, height: screenHeight * 0.08)
                                                .background(Color.green)
                                                .cornerRadius(15.0)
                            })
                        } else {
                            LoginView()
                                .frame(width: screenWidth, height: screenHeight)
                        }
                    }
                    .padding(.bottom, screenHeight * 0.1)
                    
                }
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
