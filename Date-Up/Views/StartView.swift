//
//  StartView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 27/08/2021.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var homeViewModel = HomeViewModel()
    @ObservedObject var profileViewModel = ProfileViewModel()
    
    var body: some View {
        if profileViewModel.profile?.firstName != nil && profileViewModel.profile?.lastName != nil && profileViewModel.profile?.email != nil && profileViewModel.profile?.id != nil && homeViewModel.currentProfile.profile.firstName != nil && homeViewModel.currentProfile.profile.lastName != nil && homeViewModel.currentProfile.profile.age != nil {
            LoggedUserView(homeViewModel: homeViewModel, profile: profileViewModel)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
