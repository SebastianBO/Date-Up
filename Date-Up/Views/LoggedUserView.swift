//
//  LoggedUserView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import SwiftUI

struct LoggedUserView: View {
    @ObservedObject var profileViewModel = ProfileViewModel()
    @ObservedObject var sessionStore = SessionStore()
    @State private var switchToContentView = false
    @State private var showNotifications = false
    @State private var showHome = false
    @State private var showChats = false
    @State private var showSettings = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if switchToContentView {
                ContentView()
            } else if showNotifications {
                NotificationsView()
            } else if showHome {
                HomeView()
            } else if showChats {
                ChatsView()
            } else if showSettings {
                SettingsView()
            } else {
//                if profileViewModel.profile != nil {
                if true { //!!!!!!!
                    NavigationView {
                        VStack {
                            
                        }
//                        .navigationTitle("Hello, \(profileViewModel.profile!.firstName)")
                        .navigationTitle("Hello, world!") //!!!!!!
                        .toolbar {
                            ToolbarItemGroup(placement: .bottomBar) {
                                NavigationLink(destination: HomeView(), isActive: $showHome) {
                                    Button {
                                        withAnimation {
                                            showHome = true
                                        }
                                    } label: {
                                        Label("Home", systemImage: "house")
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        showChats = true
                                    }
                                } label: {
                                    Label("Chats", systemImage: "bubble.left.and.bubble.right")
                                }
                                
                                Spacer()
                                
                                Button {
//                                    if sessionStore.signOut() {
//                                        withAnimation {
//                                            switchToContentView = true
//                                        }
//                                    }
                                    withAnimation {
                                        showSettings = true
                                    }
                                } label: {
                                    Label("Settings", systemImage: "gearshape")
                                }
                            }
                            
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                Button {
                                    withAnimation {
                                        showNotifications = true
                                    }
                                } label: {
                                    Label("Notifications", systemImage: "bell")
                                }
                            }
                        }
                    }
                    .onAppear() {
                        profileViewModel.getUserInfo()
                    }
                }
            }
        }
    }
}

struct LoggedUserView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedUserView()
    }
}
