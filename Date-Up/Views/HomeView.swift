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
                    .navigationBarTitle("Yours today's picks")
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
                if homeViewModel.allProfiles.count != 0 {
                    ForEach(homeViewModel.allProfiles) { profile in
                        ZStack {
                            TabView {
                                ForEach(profile.profileImageViews) { userPictureView in
                                    Image(uiImage: userPictureView.uiImageView.image!)
                                        .resizable()
                                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                        .frame(width: screenWidth * 0.9, height: screenHeight * 0.85, alignment: .center)
                                        .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                            
                            VStack {
                                VStack {
                                    HStack {
                                        Text(profile.profile.firstName)
                                            .font(.system(size: screenHeight * 0.05, weight: .bold))
                                                                    
                                        Text(String(profile.profile.age))
                                            .font(.system(size: screenHeight * 0.037, weight: .light))
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Image(systemName: "person.fill")
                                        
                                        Text(profile.profile.city)
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.top, screenHeight * 0.65)
                                .padding(.trailing, screenWidth * 0.30)
                                .padding(.leading, screenWidth * 0.03)
                                .foregroundColor(.white)
                                
                                Spacer()
                                
                                HStack {
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation {
                                            homeViewModel.removeProfileFromProposed(userUID: profile.id)
                                        }
                                    }, label: {
                                        Image(systemName: "multiply.circle")
                                    })
                                    .font(.system(size: screenHeight * 0.09))
                                    .foregroundColor(.red)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        
                                    }, label: {
                                        Image(systemName: "bolt.circle")
                                    })
                                    .font(.system(size: screenHeight * 0.06))
                                    .foregroundColor(.yellow)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        
                                    }, label: {
                                        Image(systemName: "message.circle")
                                    })
                                    .font(.system(size: screenHeight * 0.06))
                                    .foregroundColor(.blue)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        
                                    }, label: {
                                        Image(systemName: "heart.circle")
                                    })
                                    .font(.system(size: screenHeight * 0.09))
                                    .foregroundColor(.green)
                                    
                                    Spacer()
                                }
                                .padding(.bottom, screenHeight * 0.02)
                            }
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
