//
//  LoggedUserView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import SwiftUI

struct LoggedUserView: View {
    @ObservedObject var profileViewModel = ProfileViewModel()
    @State private var switchToContentView = false
    @State private var showHome = false
    @State private var showChats = false
    @State private var showSettings = false
    @State private var selectedTab = 0
    @State private var alreadyExisting = false
    @State private var tabBarImage: Image?
    
    let tabBarImagesNames = ["house", "bubble.left.and.bubble.right", "person"]
    let tabBarFilledImagesNames = ["house.fill", "bubble.left.and.bubble.right.fill", "person.fill"]
    
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
                            if selectedTab == number {
                                Image(systemName: tabBarFilledImagesNames[number])
                            } else {
                                Image(systemName: tabBarImagesNames[number])
                            }
                        })
                        
                        Spacer()
                    }
                }
                .font(.system(size: screenHeight * 0.03))
            }
            .onAppear() {
                profileViewModel.fetchData()
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
