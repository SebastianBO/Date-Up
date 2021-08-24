//
//  LoggedUserView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import SwiftUI

struct LoggedUserView: View {
    @ObservedObject var profileViewModel = ProfileViewModel()
    @AppStorage("isDarkMode") private var darkMode = false
    @State private var switchToContentView = false
    @State private var showHome = false
    @State private var showChats = false
    @State private var showSettings = false
    @State private var selectedTab = 0
    @State private var alreadyExisting = false
    
    let tabBarImagesNames = ["house", "bubble.left.and.bubble.right", "person"]
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                ZStack {
                    switch selectedTab {
                    case 0:
                        HomeView(profile: profileViewModel)
                        
                    case 1:
                        ChatsView(profile: profileViewModel)
                        
                    case 2:
                        ProfileView(profile: profileViewModel)
                        
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
                }
                .foregroundColor(darkMode ? .white : .black)
                .font(.system(size: screenHeight * 0.03))
            }
            .preferredColorScheme(darkMode ? .dark : .light)
            .environment(\.colorScheme, darkMode ? .dark : .light)
            .onAppear() {
                profileViewModel.getUserInfo()
            }
        }
    }
}

struct LoggedUserView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            LoggedUserView().preferredColorScheme($0)
        }
    }
}
