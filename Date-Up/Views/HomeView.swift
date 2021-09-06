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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                HomeView(profile: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
