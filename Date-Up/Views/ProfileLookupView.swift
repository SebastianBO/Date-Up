//
//  ProfileLookupView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 09/09/2021.
//

import SwiftUI

struct ProfileLookupView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @ObservedObject private var homeViewModel: HomeViewModel
    private var profileLookup: ProfileLookup
    @Environment(\.colorScheme) var colorScheme
    
    @State private var x: CGFloat = 0
    @State private var y: CGFloat = 0
    @State private var deegres: Double = 0
    
    init(homeViewModel: HomeViewModel, profile: ProfileViewModel, profileLookup: ProfileLookup) {
        self.homeViewModel = homeViewModel
        self.profileViewModel = profile
        self.profileLookup = profileLookup
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ZStack(alignment: .topLeading) {
                Image(uiImage: self.profileLookup.profileImageViews[0].uiImageView.image!)
                    .resizable()
                    .onTapGesture {
                        
                    }
                
                HStack {
                    Image(uiImage: UIImage(named: "like")!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .opacity(Double(self.x / 10 - 1))
                    
                    Spacer()
                    
                    Image(uiImage: UIImage(named: "nope")!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .opacity(Double(self.x / 10 * -1 - 1))
                }
                    
                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
            
                VStack(alignment: .leading) {
                    Spacer()
                    
                    HStack {
                        Text(self.profileLookup.profile.firstName.capitalized)
                            .font(.system(size: screenHeight * 0.05, weight: .bold))
                                                    
                        Text(String(self.profileLookup.profile.age))
                            .font(.system(size: screenHeight * 0.037, weight: .light))
                        
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "person.fill")
                        
                        Text(self.profileLookup.profile.city.capitalized)
                        
                        Spacer()
                    }
                }
                .padding()
                .padding(.bottom, screenHeight * 0.13)
                .foregroundColor(.white)
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                homeViewModel.removeProfileFromProposed(userUID: profileLookup.id)
                            }
                        }, label: {
                            Image(systemName: "multiply.circle")
                        })
                        .font(.system(size: screenHeight * 0.09))
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "bolt.circle")
                        })
                        .font(.system(size: screenHeight * 0.06))
                        .foregroundColor(.yellow)
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "message.circle")
                        })
                        .font(.system(size: screenHeight * 0.06))
                        .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "heart.circle")
                        })
                        .font(.system(size: screenHeight * 0.09))
                        .foregroundColor(.green)
                        
                        Spacer()
                    }
                    .padding(.bottom, screenHeight * 0.02)
                }
            }
            .cornerRadius(20)
            .padding()
            .offset(x: self.x, y: self.y)
            .rotationEffect(.init(degrees: self.deegres))
            .zIndex(1.0)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        withAnimation {
                            self.x = value.translation.width
                            self.y = value.translation.height
                            self.deegres = 7 * (value.translation.width > 0 ? 1: -1)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
                            switch value.translation.width {
                            case 0...100:
                                self.x = 0; self.y = 0; self.deegres = 0
                            case let x where x > 100:
                                self.x = 500; self.deegres = 12
                            case (-100)...(-1):
                                self.x = 0; self.y = 0; self.deegres = 0
                            case let x where x < -100:
                                self.x = -500; self.deegres = -12
                                self.homeViewModel.removeProfileFromProposed(userUID: profileLookup.id)
                            default:
                                self.x = 0; self.y = 0
                            }
                        }
                    }
            )
        }
    }
}

struct ProfileLookupDetailsView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @ObservedObject private var homeViewModel: HomeViewModel
    private var profileLookup: ProfileLookup
    
    private var isEditable: Bool
    
    init(homeViewModel: HomeViewModel, profile: ProfileViewModel, profileLookup: ProfileLookup, isEditable: Bool = false) {
        self.homeViewModel = homeViewModel
        self.profileViewModel = profile
        self.profileLookup = profileLookup
        self.isEditable = isEditable
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                HStack {
                    
                }
            }
        }
    }
}

struct ProfileLookupView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                ProfileLookupDetailsView(homeViewModel: homeViewModel, profile: profileViewModel, profileLookup: ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))]))
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                ProfileLookupView(homeViewModel: homeViewModel, profile: profileViewModel, profileLookup: ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))]))
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
