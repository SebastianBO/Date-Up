//
//  ChatsView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 16/08/2021.
//

import SwiftUI

struct ChatsView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @ObservedObject private var homeViewModel: HomeViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var searchConversationPattern = ""
    
    init(profile: ProfileViewModel, homeViewModel: HomeViewModel) {
        self.profileViewModel = profile
        self.homeViewModel = homeViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                HStack {
                    Text("Chats").font(.largeTitle).fontWeight(.bold)
                        .padding(.leading, screenWidth * 0.05)
                    
                    Spacer()
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .stroke()
                        .foregroundColor(.gray)
                    TextField("Search", text: $searchConversationPattern)
                        .padding(.leading, screenWidth * 0.05)
                }
                .frame(width: screenWidth * 0.9, height: screenHeight * 0.05)
                
                List(profileViewModel.chatRooms) { chatRoom in
                    if !searchConversationPattern.isEmpty ? checkIfPatternIsInMessages(firstName: homeViewModel.getProfileLookupForConversations(profileViewModel.chatRoom.users[1]).profile.firstName, messages: profileViewModel.chatRoom.messages) : (true) {
                        HStack {
                            Image(uiImage: chatRoom.users[1].profileImageViews[0].uiImageView.image!)
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: screenWidth * 0.15, height: screenHeight * 0.075)
                            
                            NavigationLink(destination: ChatRoomView(profile: profileViewModel, homeViewModel: homeViewModel)
                                            .ignoresSafeArea(.keyboard)) {
                                VStack {
                                    HStack {
                                        Text(chatRoom.users[1].profile.firstName.capitalized)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                            .fontWeight(.bold)
                                        Spacer()
                                    }
                                    HStack {
                                        Text(chatRoom.messages.last!.message)
                                        Text("|")
                                            .foregroundColor(.gray)
                                        if String(Calendar.current.component(.minute, from: chatRoom.messages.last!.timeStamp)).count == 1 {
                                            Text(String(Calendar.current.component(.hour, from: chatRoom.messages.last!.timeStamp)) + ":0" + String(Calendar.current.component(.minute, from: chatRoom.messages.last!.timeStamp)))
                                                .foregroundColor(.gray)
                                        } else {
                                            Text(String(Calendar.current.component(.hour, from: chatRoom.messages.last!.timeStamp)) + ":" + String(Calendar.current.component(.minute, from: chatRoom.messages.last!.timeStamp)))
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .frame(width: screenWidth, height: screenHeight * 0.08)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    func checkIfPatternIsInMessages(firstName: String, messages: [Message]) -> Bool {
        if firstName.lowercased().contains(self.searchConversationPattern.lowercased()) {
            return true
        }
        
        for message in messages {
            if message.message.lowercased().contains(self.searchConversationPattern.lowercased()) {
                return true
            }
        }
        return false
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel(forPreviews: true)
        let homeViewModel = HomeViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                ChatsView(profile: profileViewModel, homeViewModel: homeViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
