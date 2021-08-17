//
//  SettingsView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 16/08/2021.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @ObservedObject private var sessionStore: SessionStore
    @State private var switchToContentView = false
    
    init(profile: ProfileViewModel, sessionStore: SessionStore) {
        self.profileViewModel = profile
        self.sessionStore = sessionStore
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if switchToContentView {
                ContentView()
            } else {
                VStack {
                    Text("ProfileView")
                    
                    Button(action: {
                        if sessionStore.signOut() {
                            withAnimation {
                                switchToContentView = true
                            }
                        }
                    }, label: {
                        Text("Logout")
                    })
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel()
        let sessionStore = SessionStore()
        ProfileView(profile: profileViewModel, sessionStore: sessionStore)
    }
}
