//
//  NotificationsView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 16/08/2021.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @State private var numbers = [1, 2, 3, 4]
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                List {
                    ForEach(numbers, id: \.self) { number in
                        Text("\(number)")
                    }
                }
                .navigationBarTitle("Notifications")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarItems(trailing:
                    Button(action: {
                        withAnimation {
                            numbers.removeAll()
                        }
                    }, label: {
                        Image(systemName: "trash")
                    })
                )
            }
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                NotificationsView(profile: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
