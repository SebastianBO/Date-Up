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
    
    @Environment(\.colorScheme) var colorScheme
    
    init(homeViewModel: HomeViewModel, profile: ProfileViewModel) {
        self.homeViewModel = homeViewModel
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                VStack(spacing: screenHeight * 0.001) {
                    HStack {
                        NavigationLink(destination: NotificationsView(profile: profileViewModel), isActive: $showNotifications) {
                            Button(action: {
                                withAnimation {
                                    showNotifications = true
                                }
                            }, label: {
                                Image(systemName: "bell.fill")
                            })
                            .foregroundColor(.yellow)
                            .font(.system(size: screenHeight * 0.025))
                            .padding()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                homeViewModel.fetchData {}
                            }
                        }, label: {
                            Image(systemName: "arrow.clockwise")
                        })
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .font(.system(size: screenHeight * 0.025))
                        .padding()
                    }
                    
                    HStack {
                        Text("Today's Picks").font(.largeTitle).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .padding(.leading, screenWidth * 0.05)
                        
                        Spacer()
                    }
                    
                    ZStack {
                        if homeViewModel.allProfiles.count != 0 {
                            ForEach(homeViewModel.allProfiles) { profile in
                                ZStack() {
                                    ProfileLookupView(homeViewModel: homeViewModel, profile: profileViewModel, profileLookup: profile)
                                        .navigationBarTitle("Today's picks")
                                }
                            }
                        } else {
                            Button(action: {
                                self.homeViewModel.restoreAllRejectedUsers()
                            }, label: {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                            })
                            .frame(width: screenWidth, height: screenHeight * 0.88, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .font(.system(size: screenHeight * 0.09))
                            .foregroundColor(.green)
                        }
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        Group {
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                    HomeView(homeViewModel: homeViewModel, profile: profileViewModel)
                        .preferredColorScheme(colorScheme)
                        .previewDevice(PreviewDevice(rawValue: deviceName))
                        .previewDisplayName(deviceName)
                }
            }
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
}

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
