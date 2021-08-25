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
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                ScrollView(.vertical) {
                    Text("sample")
                }
                .navigationBarTitle(profileViewModel.profile != nil ? "Hello, \(profileViewModel.profile!.firstName)" : "Hello, World")
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) {
            HomeView(profile: profileViewModel).preferredColorScheme($0)
        }
    }
}
