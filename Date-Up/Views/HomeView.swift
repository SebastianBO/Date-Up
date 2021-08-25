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
    @AppStorage("isDarkMode") private var darkMode = false
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack(spacing: screenHeight * -0.887) {
                TopView()
                    .frame(width: screenWidth, height: screenHeight)
                
                NavigationView {
                    if profileViewModel.profile != nil {
                        Text("sample")
                            .navigationTitle("Hello, \(profileViewModel.profile!.firstName)")
                            .toolbar(content: {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        withAnimation {
                                            showNotifications = true
                                        }
                                    }, label: {
                                        Image(systemName: "bell")
                                    })
                                }
                            })
                    } else {
                        Text("sample")
                            .navigationTitle("Hello, world!")
                            .toolbar(content: {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        withAnimation {
                                            showNotifications = true
                                        }
                                    }, label: {
                                        Image(systemName: "bell")
                                    })
                                }
                            })
                    }
                }
            }
            .preferredColorScheme(darkMode ? .dark : .light)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel()
        ForEach(ColorScheme.allCases, id: \.self) {
            HomeView(profile: profileViewModel).preferredColorScheme($0)
        }
    }
}
