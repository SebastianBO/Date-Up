//
//  LoggedUserView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import SwiftUI

struct LoggedUserView: View {
    @ObservedObject private var homeViewModel: HomeViewModel
    @ObservedObject private var profileViewModel: ProfileViewModel
    
    let tabBarImagesNames = ["house", "bubble.left.and.bubble.right", "person"]
    let tabBarFilledImagesNames = ["house.fill", "bubble.left.and.bubble.right.fill", "person.fill"]
    
    init(homeViewModel: HomeViewModel, profile: ProfileViewModel) {
        self.homeViewModel = homeViewModel
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            TabView {
                HomeView(homeViewModel: homeViewModel, profile: profileViewModel)
                    .tabItem {
                        Image(systemName: "house.fill")
                    }
                    .tag(0)
                
                ChatsView(profile: profileViewModel)
                    .tabItem {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                    }
                    .tag(1)
                
                ProfileView(profile: profileViewModel)
                    .tabItem {
                        Image(systemName: "person.fill")
                    }
                    .tag(2)
            }
        }
    }
}

struct LoggedUserView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                LoggedUserView(homeViewModel: homeViewModel, profile: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
