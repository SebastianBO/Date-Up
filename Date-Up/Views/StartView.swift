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
                if switchToLoginView {
                    LoginView()
                }
                VStack {
                    Text("Date-Up!")
                        .padding(.top, screenHeight * 0.05)
                        .font(.system(size: screenHeight * 0.05))
                    
                    Spacer()
                    
                    VStack (spacing: screenHeight * 0.03) {
                        Button(action: {
                            hideButtons.toggle()
                            switchToLoginView.toggle()
                        }, label: {
                            Text("Login")
                                .font(.system(size: screenHeight * 0.035))
                                .background(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                                                .foregroundColor(.yellow)
                                                .frame(width: screenWidth * 0.4, height: screenHeight * 0.065))
                        })
                        
                        
                        Button(action: {
                            switchToRegisterView.toggle()
                        }, label: {
                            Text("Register")
                                .font(.system(size: screenHeight * 0.035))
                                .background(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                                                .foregroundColor(.yellow)
                                                .frame(width: screenWidth * 0.4, height: screenHeight * 0.065))
                        })
                        
                    }
                    .padding(.bottom, screenHeight * 0.1)
                    .frame(height: hideButtons ? 0 : screenHeight * 0.05)
                }
                .frame(width: screenWidth, height: screenHeight)
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
