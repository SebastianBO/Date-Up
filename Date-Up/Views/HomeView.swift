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
                ZStack {
                    if homeViewModel.allProfiles.count != 0 {
                        ForEach(homeViewModel.allProfiles) { profile in
                            ZStack() {
                                ProfileLookupView(homeViewModel: homeViewModel, profile: profileViewModel, profileLookup: profile)
                                    .navigationBarTitle("Today's picks")
                                    .navigationBarItems(trailing:
                                        NavigationLink(destination: NotificationsView(profile: profileViewModel), isActive: $showNotifications) {
                                            Button(action: {
                                                withAnimation {
                                                    homeViewModel.fetchData {}
                                                }
                                            }, label: {
                                                Image(systemName: "arrow.clockwise")
                                            })
                                            
                                            Button(action: {
                                                withAnimation {
                                                    showNotifications.toggle()
                                                }
                                            }, label: {
                                                Image(systemName: "bell")
                                            })
//                                            .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
//                                                        .onEnded { value in
//                                                            let horizontalAmount = value.translation.width as CGFloat
//                                                            let verticalAmount = value.translation.height as CGFloat
//
//                                                            if abs(horizontalAmount) > abs(verticalAmount) {
//                                                                if horizontalAmount < 0 {
//                                                                    // left swipe
//                                                                    withAnimation {
//                                                                        self.homeViewModel.removeProfileFromProposed(userUID: profile.id)
//                                                                    }
//                                                                } else {
//                                                                    // right swipe
//                                                                    withAnimation {
//
//                                                                    }
//                                                                }
//                                                            } else {
//                                                                if verticalAmount < 0 {
//                                                                    // up swipe
//                                                                    withAnimation {
//
//                                                                    }
//                                                                } else {
//                                                                    // down swipe
//                                                                    withAnimation {
//
//                                                                    }
//                                                                }
//                                                            }
//                                                        })
                                    }
                                )
                            }
                        }
                    } else {
                        Button(action: {
                            self.homeViewModel.restoreAllRejectedUsers()
                        }, label: {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                        })
                        .font(.system(size: screenHeight * 0.09))
                        .foregroundColor(.green)
                    }
                }
            }
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
