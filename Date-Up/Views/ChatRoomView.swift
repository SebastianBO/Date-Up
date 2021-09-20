//
//  ChatRoomView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 11/09/2021.
//

import SwiftUI

struct ChatRoomView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @ObservedObject private var homeViewModel: HomeViewModel
    private var chatRoom: ChatRoom
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var messageToBeSend = ""
    @State var sendDisabled = true
    
    init(profile: ProfileViewModel, homeViewModel: HomeViewModel, chatRoom: ChatRoom) {
        self.profileViewModel = profile
        self.homeViewModel = homeViewModel
        self.chatRoom = chatRoom
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            

                VStack {
                    if self.chatRoom.messages.count != 0 {
                        ScrollView(.vertical) {
                            ForEach(self.chatRoom.messages) { message in
                                Spacer()
                                if message.user == profileViewModel.profile!.id {
                                    HStack {
                                        Spacer()
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 23)
                                                .foregroundColor(.blue)
                                            Text(message.message!)
                                                .foregroundColor(.white)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .frame(minWidth: screenWidth * 0.50, idealWidth: screenWidth * 0.55, maxWidth: screenWidth * 0.6, minHeight: screenHeight * 0.08, idealHeight: screenHeight * 0.08, maxHeight: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                    }
                                } else {
                                    HStack {
                                        VStack {
                                            Spacer()
                                            Image(uiImage: self.chatRoom.profileLookups![1].profileImageViews[0].uiImageView.image!)
                                                .resizable()
                                                .clipShape(Circle())
                                                .frame(width: screenWidth * 0.10, height: screenHeight * 0.05)
                                        }
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 23)
                                                .foregroundColor(.gray)
                                            Text(message.message!)
                                                .foregroundColor(.white)
                                                .background(RoundedRectangle(cornerRadius: 23)
                                                                .foregroundColor(.gray))
                                        }
                                        .frame(minWidth: screenWidth * 0.50, idealWidth: screenWidth * 0.55, maxWidth: screenWidth * 0.6, minHeight: screenHeight * 0.08, idealHeight: screenHeight * 0.08, maxHeight: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                
                            }
                        }, label: {
                            Image(systemName: "camera.fill")
                                .font(.system(size: screenHeight * 0.03))
                        })
                        
                        Button(action: {
                            withAnimation {
                                
                            }
                        }, label: {
                            Image(systemName: "photo")
                                .font(.system(size: screenHeight * 0.03))
                        })
                        
                        Spacer()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                                .stroke()
                                .foregroundColor(self.messageToBeSend.isEmpty == true ? .gray : .blue)
                            TextField("Aa", text: $messageToBeSend)
                                .padding(.horizontal, screenWidth * 0.05)
                        }
                        .frame(width: screenWidth * 0.6, height: screenHeight * 0.05)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                self.profileViewModel.sendMessageToDatabase(chatID: chatRoom.id.uuidString, message: messageToBeSend) {
                                    self.profileViewModel.fetchData {
                                        print("Fetching Data")
                                    }
                                }
                            }
                        }, label: {
                            Image(systemName: "paperplane")
                                .font(.system(size: screenHeight * 0.035))
                        })
                        .disabled(self.messageToBeSend.isEmpty)
                        
                        Spacer()
                    }
                }
                .navigationBarTitle("XYZ", displayMode: .inline)
                .keyboardAdaptive()
        }
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel(forPreviews: true)
        let homeViewModel = HomeViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                ChatRoomView(profile: profileViewModel, homeViewModel: homeViewModel, chatRoom: ChatRoom(users: ["69", "96"], messages: [Message(message: "message1", picture: nil, timeStamp: Date(), user: "69"), Message(message: "message2", picture: nil, timeStamp: Date(), user: "69"), Message(message: "message3", picture: nil, timeStamp: Date(), user: "96")]))
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
