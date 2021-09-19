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
    
    private var users = [ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))]), ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))])]
    
    private var messages: [Message]
    
    private var chatRooms: [ChatRoom]
    
    init(profile: ProfileViewModel, homeViewModel: HomeViewModel) {
        self.profileViewModel = profile
        self.homeViewModel = homeViewModel
        self.messages = [Message(message: "Message1", user: self.users[0]), Message(message: "Message2", user: self.users[1])]
        self.chatRooms = [ChatRoom(users: [users[0], users[1]], messages: [messages[0], messages[1]], photos: nil), ChatRoom(users: [users[0], users[1]], messages: [messages[0], messages[1]], photos: nil), ChatRoom(users: [users[0], users[1]], messages: [messages[0], messages[1]], photos: nil)]
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
                
                List(chatRooms) { chatRoom in
                    if !searchConversationPattern.isEmpty ? checkIfPatternIsInMessages(firstName: chatRoom.users[1].profile.firstName, messages: chatRoom.messages) : (true) {
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
