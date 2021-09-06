//
//  HomeView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 16/08/2021.
//

import SwiftUI

struct HomeView: View {
    @State private var showNotifications = false
    @ObservedObject private var profileViewModel: ProfileViewModel
    @ObservedObject private var homeViewModel: HomeViewModel
    
    init(homeViewModel: HomeViewModel, profile: ProfileViewModel) {
        self.homeViewModel = homeViewModel
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                ProfileExplorerView(homeViewModel: homeViewModel)
                    .navigationBarTitle("Hello, \(profileViewModel.profile!.firstName)")
                    .navigationBarItems(trailing:
                        NavigationLink(destination: NotificationsView(profile: profileViewModel), isActive: $showNotifications) {
                            Button(action: {
                                withAnimation {
                                    showNotifications.toggle()
                                }
                            }, label: {
                                Image(systemName: "bell")
                            })
                        }
                    )
            }
        }
    }
}

struct ProfileExplorerView: View {
    @ObservedObject private var homeViewModel: HomeViewModel
    
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ZStack {
                TabView {
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.gray)
                    ForEach(homeViewModel.allProfiles, id: \.self) { profile in
                        Text(profile.profile.firstName)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
            }
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onEnded({ value in
                                    if value.translation.width < 0 {
                                        // left
                                    }

                                    if value.translation.width > 0 {
                                        // right
                                    }
                                    if value.translation.height < 0 {
                                        // up
                                    }

                                    if value.translation.height > 0 {
                                        // down
                                    }
                                }))
            .frame(width: screenWidth * 0.93, height: screenHeight * 0.85)
            .padding(.all, screenWidth * 0.035)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                HomeView(homeViewModel: homeViewModel, profile: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
