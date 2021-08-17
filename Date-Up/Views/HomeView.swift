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
            
            VStack(spacing: screenHeight * -0.887) {
                TopView()
                    .frame(width: screenWidth, height: screenHeight)
                
                NavigationView {
                    Text("sample")
//                            .navigationTitle("Hello, \(profileViewModel.profile!.firstName)")
                        .navigationTitle("Hello, world!") //!!!!!!
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
                .accentColor(.black)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel()
        HomeView(profile: profileViewModel)
    }
}
