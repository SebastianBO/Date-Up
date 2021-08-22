//
//  SettingsView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 16/08/2021.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    private let textFieldColor = Color("TextFieldsColor")
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var bio = ""
    @State private var preference = ""
    private var preferenceValues = ["Men", "Women", "Both"]
    @State private var editMode = false
    @State private var isActivePhoto = false
    
    @State private var images: [Image]? = [Image("blank-profile-hi"), Image("blank-profile-hi"), Image("blank-profile-hi")]
    @State private var image: Image? = Image("blank-profile-hi")
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentActionScheet = false
    @State private var shouldPresentCamera = false
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ScrollView(.vertical) {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            profileViewModel.session.signOut()
                        }, label: {
                            Image(systemName: "person.badge.minus")
                        })
                        .padding(.trailing, screenWidth * 0.1)
                        .padding(.top, screenHeight * 0.03)
                    }
                    .foregroundColor(.black)
                    .font(.system(size: screenHeight * 0.03))
                    
                    VStack {
                        if !isActivePhoto {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(0..<images!.count, id: \.self) { imageIndex in
                                        images![imageIndex]
                                            .resizable()
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                            .frame(width: isActivePhoto ? screenWidth * 0.6 : screenWidth * 0.2, height: isActivePhoto ? screenHeight * 0.3 : screenHeight * 0.1)
                                            .shadow(radius: isActivePhoto ? 10 : 0)
                                            .onTapGesture {
                                                withAnimation {
                                                    self.shouldPresentActionScheet = true
                                                    self.isActivePhoto.toggle()
                                                }
                                            }
        //                                    .sheet(isPresented: $shouldPresentImagePicker) {
        //                                        SUImagePickerView(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, image: $images![0], isPresented: self.$shouldPresentImagePicker)
        //                                    }
        //                                    .actionSheet(isPresented: $shouldPresentActionScheet) {
        //                                        ActionSheet(title: Text("Add a new profile picture"), message: nil,
        //                                            buttons: [ActionSheet.Button.default(Text("Camera"), action: {
        //                                                self.shouldPresentImagePicker = true
        //                                                self.shouldPresentCamera = true
        //                                            }), ActionSheet.Button.default(Text("Photo Library"), action: {
        //                                                self.shouldPresentImagePicker = true
        //                                                self.shouldPresentCamera = false
        //                                            }), ActionSheet.Button.cancel()])
        //
        //                                    }
                                    }
                                }
                                .frame(width: screenWidth, height: screenHeight * 0.12)
                            }
                        } else {
                            TabView {
                                ForEach(0..<images!.count, id: \.self) { imageIndex in
                                    images![imageIndex]
                                        .resizable()
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                        .frame(width: isActivePhoto ? screenWidth * 0.6 : screenWidth * 0.2, height: isActivePhoto ? screenHeight * 0.3 : screenHeight * 0.1)
                                        .shadow(radius: isActivePhoto ? 10 : 0)
                                        .onTapGesture {
                                            withAnimation {
                                                self.shouldPresentActionScheet = true
                                                self.isActivePhoto.toggle()
                                            }
                                        }
    //                                    .sheet(isPresented: $shouldPresentImagePicker) {
    //                                        SUImagePickerView(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, image: $images![0], isPresented: self.$shouldPresentImagePicker)
    //                                    }
    //                                    .actionSheet(isPresented: $shouldPresentActionScheet) {
    //                                        ActionSheet(title: Text("Add a new profile picture"), message: nil,
    //                                            buttons: [ActionSheet.Button.default(Text("Camera"), action: {
    //                                                self.shouldPresentImagePicker = true
    //                                                self.shouldPresentCamera = true
    //                                            }), ActionSheet.Button.default(Text("Photo Library"), action: {
    //                                                self.shouldPresentImagePicker = true
    //                                                self.shouldPresentCamera = false
    //                                            }), ActionSheet.Button.cancel()])
    //
    //                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .frame(width: screenWidth, height: screenHeight * 0.35)
                        }
                        
                        
                        Button(action: {
                            withAnimation {
                                if editMode {
                                    if profileViewModel.firstNameChange(firstName: firstName) {
                                        profileViewModel.session.editUserFirstNameInDatabase(firstName: firstName)
                                    }
                                    if profileViewModel.lastNameChange(lastName: lastName) {
                                        profileViewModel.session.editUserLastNameInDatabase(lastName: lastName)
                                    }
                                    if profileViewModel.bioChange(bio: bio) {
                                        profileViewModel.session.editUserBioInDatabase(bio: bio)
                                    }
                                    if profileViewModel.preferenceChange(preference: preference) {
                                        profileViewModel.session.editUserPreferenceInDatabase(preference: preference)
                                    }
                                }
                                profileViewModel.getUserInfo()
                                editMode.toggle()
                            }
                        }, label: {
                            Image(systemName: editMode ? "pencil.circle.fill" : "pencil.circle")
                        })
                        .padding(.top, screenHeight * 0.03)
                        .foregroundColor(.black)
                        .font(.system(size: screenHeight * 0.03))
                        
                        Spacer()
                        
                        if profileViewModel.profile != nil {
                            Group {
                                TextField(profileViewModel.profile!.firstName, text: $firstName)

                                TextField(profileViewModel.profile!.lastName, text: $lastName)

                                TextField(profileViewModel.profile!.bio, text: $bio)
                                    .padding(.bottom, screenHeight * 0.1)
                                    .lineLimit(4)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .background(textFieldColor)
                            .cornerRadius(5.0)
                            .disabled(editMode ? false : true)

                            Text("Preference:")
                                .padding(.trailing, screenWidth * 0.65)
                                .padding(.top, screenHeight * 0.05)
                            Picker("preference", selection: $preference) {
                                ForEach(preferenceValues, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom, screenHeight * 0.05)
                            .disabled(editMode ? false : true)
                            
                        } else {
                            Text("ProfileView: The profile is nil!")
                        }
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel()
        Group {
            ProfileView(profile: profileViewModel)
        }
    }
}
