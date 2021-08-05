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
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                VStack {
                    TextField("e-mail", text: $email)
                    SecureField("password", text: $password)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.top, screenHeight * 0.6)
            }
            .frame(width: screenWidth, height: screenHeight, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
