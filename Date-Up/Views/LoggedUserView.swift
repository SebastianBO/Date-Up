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
    @State private var showHome = false
    @State private var showChats = false
    @State private var showSettings = false
    @State private var selectedTab = 0
    
    let tabBarImagesNames = ["house", "bubble.left.and.bubble.right", "person"]
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
//            if profileViewModel.profile != nil {
            if true { //!!!!!!!
                VStack {
                    ZStack {
                        switch selectedTab {
                        case 0:
                            HomeView(profile: profileViewModel)
                            
                        case 1:
                            ChatsView(profile: profileViewModel)
                            
                        case 2:
                            ProfileView(profile: profileViewModel, sessionStore: sessionStore)
                            
                        default:
                            Text("ERROR!")
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        ForEach(0..<3) { number in
                            Spacer()
                            
                            Button(action: {
                                selectedTab = number
                            }, label: {
                                Image(systemName: tabBarImagesNames[number])
                            })
                            
                            Spacer()
                        }

//
//                        Spacer()
//
//                        Button(action: {
////                            if sessionStore.signOut() {
////                                withAnimation {
////                                    switchToContentView = true
////                                }
////                            }
//                            withAnimation {
//                                showSettings = true
//                            }
//                        }, label: {
//                            Image(systemName: "person")
//                        })
//
//                        Spacer()
                    }
                    .foregroundColor(.black)
                    .font(.system(size: screenHeight * 0.03))
                }
                .onAppear() {
                    profileViewModel.getUserInfo()
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
