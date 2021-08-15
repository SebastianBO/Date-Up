//
//  LoggedUserView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import SwiftUI

struct LoggedUserView: View {
    @ObservedObject var profileViewModel = ProfileViewModel()
    @ObservedObject var sessionStore = SessionStore()
    @State private var switchToContentView = false
    
    init() {
        profileViewModel.fetchData()
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if switchToContentView {
                ContentView()
            } else {
                VStack {
                    Button(action: {
                        if sessionStore.signOut() {
                            withAnimation {
                                switchToContentView = true
                            }
                        }
                    }, label: {
                        Text("Logout")
                            .font(.system(size: screenHeight * 0.026))
                                        .foregroundColor(.white)
                                        .padding()
                            .frame(minWidth: screenWidth * 0.4, maxHeight: screenHeight * 0.08)
                                        .background(Color.green)
                                        .cornerRadius(15.0)
                    })
                    
                    Text("Hello world!")
                }
            }
        }
    }
}

struct LoggedUserView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedUserView()
    }
}
