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
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var messageToBeSend = ""
    @State var sendDisabled = true
    
    private var users = [ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))]), ProfileLookup(profile: Profile(id: "70", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))])]
    
    @State private var messages = [Message]()
    
    init(profile: ProfileViewModel, homeViewModel: HomeViewModel) {
        self.profileViewModel = profile
        self.homeViewModel = homeViewModel
        self.messages = [Message(message: "Message1", user: self.users[0]), Message(message: "Message2", user: self.users[1])]
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            

                VStack {
                    ScrollView(.vertical) {
                        ForEach(messages) { message in
                            Spacer()
                            if message.user.id == profileViewModel.profile!.id {
                                HStack {
                                    Spacer()
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 23)
                                            .foregroundColor(.blue)
                                        Text(message.message)
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(minWidth: screenWidth * 0.50, idealWidth: screenWidth * 0.55, maxWidth: screenWidth * 0.6, minHeight: screenHeight * 0.08, idealHeight: screenHeight * 0.08, maxHeight: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                }
                            } else {
                                HStack {
                                    VStack {
                                        Spacer()
                                        Image(uiImage: self.users[1].profileImageViews[0].uiImageView.image!)
                                            .resizable()
                                            .clipShape(Circle())
                                            .frame(width: screenWidth * 0.10, height: screenHeight * 0.05)
                                    }
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 23)
                                            .foregroundColor(.gray)
                                        Text(message.message)
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
                                self.messages.append(Message(message: self.messageToBeSend, user: ProfileLookup(profile: self.profileViewModel.profile!, profileImageViews: self.profileViewModel.userPicturesView)))
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
        .onAppear {
            self.messages = [Message(message: "Message1", user: self.users[0]), Message(message: "Message2", user: self.users[1])]
        }
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel(forPreviews: true)
        let homeViewModel = HomeViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                ChatRoomView(profile: profileViewModel, homeViewModel: homeViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
