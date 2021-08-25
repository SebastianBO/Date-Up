//
//  NotificationsView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 16/08/2021.
//

import SwiftUI

struct NotificationsView: View {
    @AppStorage("isDarkMode") private var darkMode = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                Text("Notifications View")
            }
            .preferredColorScheme(darkMode ? .dark : .light)
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            NotificationsView().preferredColorScheme($0)
        }
    }
}
