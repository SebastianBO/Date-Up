//
//  ProfileLookup.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 06/09/2021.
//

import Foundation
import SwiftUI

struct ProfileLookup: Identifiable, Hashable, Equatable {
    var id: String
    public var profile: Profile
    public var profileImageViews: [PictureView]
    
    init(profile: Profile, profileImageViews: [PictureView]) {
        self.profile = profile
        self.id = self.profile.id
        self.profileImageViews = profileImageViews
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: ProfileLookup, rhs: ProfileLookup) -> Bool {
        lhs.id == rhs.id
    }
}
