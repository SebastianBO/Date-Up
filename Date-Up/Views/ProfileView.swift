//
//  SettingsView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 16/08/2021.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private let textFieldColor = Color("TextFieldsColor")
    
    @State private var editMode = false
    
    @State private var shouldPresentSettings = false
    
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
            
            NavigationView {
                ScrollView {
                    VStack {
                        HStack {
                            Button(action: {
                                self.shouldPresentAddActionSheet = true
                            }, label: {
                                Image(systemName: "plus.circle")
                            })
                            .padding(.leading, screenWidth * 0.05)
                            .padding(.top, screenHeight * 0.03)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            Spacer()
                            
                            NavigationLink(destination: SettingsView(profile: profileViewModel), isActive: $shouldPresentSettings) {
                                Button(action: {
                                    self.shouldPresentSettings = true
                                }, label: {
                                    Image(systemName: "gearshape")
                                })
                                .padding(.trailing, screenWidth * 0.1)
                                .padding(.top, screenHeight * 0.03)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
        
                        }
                        .font(.system(size: screenHeight * 0.03))
                        .sheet(isPresented: $shouldPresentImagePicker) {
                            ImagePicker(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, selectedImage: self.$image)
                                .onDisappear {
                                    let queue = OperationQueue()
                                    var uploadedImageURL = ""
                                    queue.addOperation {
                                        uploadedImageURL = profileViewModel.firebaseStorageManager.uploadImageToStorage(image: image, userID: profileViewModel.profile!.id)
                                        profileViewModel.addImageURLToUserImages(imageURL: uploadedImageURL)
                                    }
                                    queue.waitUntilAllOperationsAreFinished()
                                    
                                    print("1 ProfileView uploadedImage URL ---------------")
                                    print(uploadedImageURL)
                                    print("1 ---------------")
                                    
                                    let newPhotos = profileViewModel.downloadUserPhotos()
                                    for photoIndex in 0..<newPhotos.count {
                                        self.profileViewModel.userPictures.append(newPhotos[photoIndex])
                                    }
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
                            Image(uiImage: profileViewModel.userPictures[0])
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: screenWidth * 0.7, height: screenHeight * 0.35)
                                .shadow(radius: 10)
                            
                            Text(profileViewModel.profile!.firstName + " " + profileViewModel.profile!.lastName)
                                .font(.title2)
                                .padding(.bottom, screenHeight * 0.02)
                            Text(profileViewModel.profile!.bio)
                            
                            NavigationLink(destination: EditView(profile: profileViewModel), isActive: $editMode) {
                                Button(action: {
                                    withAnimation {
                                        editMode.toggle()
                                    }
                                }, label: {
                                    HStack {
                                        Image(systemName: "pencil.circle")
                                        Text("Edit profile")
                                    }
                                })
                                .padding(.top, screenHeight * 0.03)
                                .font(.system(size: screenHeight * 0.02))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                        }
                            
                        ScrollView() {
                            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                ForEach(0..<profileViewModel.userPictures.count, id: \.self) { imageIndex in
                                    Image(uiImage: profileViewModel.userPictures[imageIndex])
                                        .resizable()
                                        .border(Color.black, width: 0.25)
                                        .frame(width: screenWidth * 0.34, height: screenHeight * 0.17)
                                        .onLongPressGesture {
                                            withAnimation {
                                                self.shouldPresentEditActionSheet = true
                                            }
                                        }
                                        .actionSheet(isPresented: $shouldPresentEditActionSheet) {
                                            ActionSheet(title: Text("Edit selected"), message: nil, buttons: [
                                                .destructive(Text("Delete this photo"), action: {
                                                    withAnimation {
//                                                        self.profileViewModel.userPictures.remove(at: imageIndex)
                                                    }
                                                }),
                                                .cancel()
                                            ])
                                        }
                                }
                            }
                        }
                    }
                    .navigationBarHidden(true)
                }
            }
        }
    }
}


struct SettingsView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    
    @State private var shouldPresentActionSheet = false
    @State private var shouldPresentLogoutSheet = false
    
    @State private var deleteUserWasPrompted = false
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
                Form {
                    Section(header: Text("Chats")) {
                        Toggle(isOn: .constant(false), label: {
                            Text("Hide my activity status")
                        })
                    }
                    
                    Section(header: Text("Account")) {
                        Button(action: {
                            shouldPresentActionSheet = true
                            shouldPresentLogoutSheet = true
                        }, label: {
                            Text("Logout")
                                .foregroundColor(.red)
                        })
                        
                        Button(action: {
                            shouldPresentActionSheet = true
                            shouldPresentLogoutSheet = false
                        }, label: {
                            Text("Delete account")
                                .foregroundColor(.red)
                        })
                    }
                    
                    Section(header: Text("Additional")) {
                        Label("Follow me on GitHub:", systemImage: "link")
                            .font(.system(size: 17, weight: .semibold))
                        Link("@Vader20FF", destination: URL(string: "https://github.com/Vader20FF")!)
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                .navigationBarTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
                
                .sheet(isPresented: $deleteUserWasPrompted, content: {
                    DeleteAccountSheetView(profile: profileViewModel)
                })
                .actionSheet(isPresented: $shouldPresentActionSheet) {
                    if shouldPresentLogoutSheet {
                        return ActionSheet(title: Text("Logout"), message: Text("Are you sure you want to logout?"), buttons: [
                            .destructive(Text("Logout"), action: {
                                profileViewModel.session.signOut()
                             }),
                            .cancel()
                        ])
                    } else {
                        return ActionSheet(title: Text("Delete Account"), message: Text("Are you sure you want to delete your account? All data will be lost."), buttons: [
                            .destructive(Text("Delete my account"), action: {
                                deleteUserWasPrompted = true
                             }),
                            .cancel()
                        ])
                    }
                }
            }
    }
}

struct EditView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var bio = ""
    @State private var preference = ""
    private var preferenceValues = ["Men", "Women", "Both"]
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            Form {
                VStack {
                    HStack {
                        Text("First Name")
                        Divider()
                        Spacer(minLength: screenWidth * 0.06)
                        TextField(profileViewModel.profile!.firstName, text: $firstName)
                    }
                    
                    HStack {
                        Text("Last Name")
                        Divider()
                        Spacer(minLength: screenWidth * 0.06)
                        TextField(profileViewModel.profile!.lastName, text: $lastName)
                    }
                    
                    HStack {
                        Text("Bio")
                        Divider()
                        Spacer(minLength: screenWidth * 0.06)
                        TextField(profileViewModel.profile!.bio, text: $bio)
                    }
                    
                    HStack {
                        Text("Preference")
                        Divider()
                        Spacer(minLength: screenWidth * 0.06)
                        Picker("preference", selection: $preference) {
                            ForEach(preferenceValues, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
            }
            .navigationBarTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button(action: {
                    withAnimation {
                        if profileViewModel.firstNameChange(firstName: firstName) {
                            profileViewModel.firestoreManager.editUserFirstNameInDatabase(firstName: firstName)
                        }
                        if profileViewModel.lastNameChange(lastName: lastName) {
                            profileViewModel.firestoreManager.editUserLastNameInDatabase(lastName: lastName)
                        }
                        if profileViewModel.bioChange(bio: bio) {
                            profileViewModel.firestoreManager.editUserBioInDatabase(bio: bio)
                        }
                        if profileViewModel.preferenceChange(preference: preference) {
                            profileViewModel.firestoreManager.editUserPreferenceInDatabase(preference: preference)
                        }
                        
                        profileViewModel.fetchData()
                        
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }, label: {
                    Text("Finished")
                })
            )
        }
    }
}

struct DeleteAccountSheetView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var email = ""
    @State private var password = ""
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
        
            NavigationView {
                VStack {
                    Form {
                        Section(footer: Text("Before you delete your account please provide your login credentials to confirm it is really you.")) {
                            TextField("E-mail", text: $email)
                            SecureField("Password", text: $password)
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            presentationMode.wrappedValue.dismiss()
                            profileViewModel.session.deleteUser(email: email, password: password)
                        }
                    }, label: {
                        Text("Delete account permanently")
                    })
                    .frame(width: screenWidth * 0.7, height: screenHeight * 0.08)
                    .background(Color.green)
                    .cornerRadius(15.0)
                    .font(.system(size: screenHeight * 0.026))
                    .foregroundColor(.white)
                    .padding()
                }
                .navigationBarHidden(true)
                .ignoresSafeArea(.keyboard)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel(forPreviews: true)
        Group {
            ForEach(ColorScheme.allCases, id: \.self) {
                ProfileView(profile: profileViewModel).preferredColorScheme($0)
                SettingsView(profile: profileViewModel).preferredColorScheme($0)
                EditView(profile: profileViewModel).preferredColorScheme($0)
            }
        }
    }
}
