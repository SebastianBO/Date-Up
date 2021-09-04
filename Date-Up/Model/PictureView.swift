//
//  PictureView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 04/09/2021.
//

import Foundation
import SwiftUI

struct PictureView: Identifiable, Hashable {
    var id: String
    var uiImageView: UIImageView
    
    init(id: String, uiImageView: UIImageView) {
        self.id = id
        self.uiImageView = uiImageView
    }
}
