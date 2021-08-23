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
    
    @State private var shouldPresentSettings = false
    
    @State private var images = [UIImage(named: "blank-profile-hi"), UIImage(named: "blank-profile-hi"), UIImage(named: "blank-profile-hi")]
    @State private var image = UIImage()
    @State private var shouldPresentAddActionSheet = false
    @State private var shouldPresentEditActionSheet = false
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentCamera = false
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if self.shouldPresentSettings {
                withAnimation {
                    SettingsView(profile: profileViewModel)
                }
            } else {
                ScrollView(.vertical) {
                    VStack {
                        HStack {
                            Button(action: {
                                self.shouldPresentAddActionSheet = true
                            }, label: {
                                Image(systemName: "plus.circle")
                            })
                            .padding(.leading, screenWidth * 0.05)
                            .padding(.top, screenHeight * 0.03)
                            
                            Spacer()
                            
                            Button(action: {
                                shouldPresentSettings = true
                            }, label: {
                                Image(systemName: "gearshape")
                            })
                            .padding(.trailing, screenWidth * 0.1)
                            .padding(.top, screenHeight * 0.03)
        
                        }
                        .foregroundColor(.black)
                        .font(.system(size: screenHeight * 0.03))
                        .sheet(isPresented: $shouldPresentImagePicker) {
                            ImagePicker(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, selectedImage: self.$image)
                                .onDisappear {
                                    images.append(image)
                                }
                        }
                        .actionSheet(isPresented: $shouldPresentAddActionSheet) {
                            ActionSheet(title: Text("Add a new photo"), message: nil, buttons: [
                                .default(Text("Take a new photo"), action: {
                                     self.shouldPresentImagePicker = true
                                     self.shouldPresentCamera = true
                                 }),
                                .default(Text("Upload a new photo"), action: {
                                     self.shouldPresentImagePicker = true
                                     self.shouldPresentCamera = false
                                 }),
                                ActionSheet.Button.cancel()
                            ])
                        }
                        
                        VStack {
                            TabView {
                                ForEach(0..<images.count, id: \.self) { imageIndex in
                                    Image(uiImage: images[imageIndex]!)
                                        .resizable()
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black, lineWidth: 0.5))
                                        .frame(width: isActivePhoto ? screenWidth * 0.9 : screenWidth * 0.5, height: isActivePhoto ? screenHeight * 0.45 : screenHeight * 0.25)
                                        .shadow(radius: isActivePhoto ? 10 : 0)
                                        .onTapGesture {
                                            withAnimation {
                                                self.isActivePhoto.toggle()
                                            }
                                        }
                                        .onLongPressGesture {
                                            withAnimation {
                                                self.shouldPresentEditActionSheet = true
                                            }
                                        }
                                        .actionSheet(isPresented: $shouldPresentEditActionSheet) {
                                            ActionSheet(title: Text("Edit selected"), message: nil, buttons: [
                                                .destructive(Text("Delete this photo"), action: {
                                                    withAnimation {
                                                        self.images.remove(at: imageIndex)
                                                    }
                                                }),
                                                .cancel()
                                            ])
                                        }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .frame(width: screenWidth, height: isActivePhoto ? screenHeight * 0.55 : screenHeight * 0.27)
                            
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
}


struct SettingsView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Display")) {
                    Toggle(isOn: .constant(false), label: {
                        Text("Dark mode")
                    })
                }
                
                Section(header: Text("Chats")) {
                    Toggle(isOn: .constant(false), label: {
                        Text("Hide my activity status")
                    })
                }
                
                Section(header: Text("Account")) {
                    Button(action: {
                        profileViewModel.session.signOut()
                    }, label: {
                        Text("Logout")
                            .foregroundColor(.red)
                    })
                    
                    Button(action: {
                        
                    }, label: {
                        Text("Delete account")
                            .foregroundColor(.red)
                    })
                }
                
                Section {
                    Label("Follow me on GitHub @Vader20FF", systemImage: "link")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel()
        Group {
            ProfileView(profile: profileViewModel)
            SettingsView(profile: profileViewModel)
        }
    }
}
