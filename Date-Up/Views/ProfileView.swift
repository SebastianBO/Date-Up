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
    
    @State private var selectedItem : PictureView? = nil
    
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
            
            ScrollView {
                VStack {
                    VStack {
                        ZStack(alignment: .bottomTrailing) {
                            Image(uiImage: self.profileViewModel.userProfilePicture.uiImageView.image!)
                                .resizable()
                                .frame(width: screenWidth, height: screenHeight * 0.4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .ignoresSafeArea()
                                .onAppear {
                                    if profileViewModel.userProfilePicture.id == "nil" {
                                        profileViewModel.fetchPhotos {
                                            print("Fetched user's photos again in order to restore profile picture")
                                        }
                                    }
                                }
                            
                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                            
                            Button(action: {
                                self.shouldPresentAddActionSheet = true
                            }, label: {
                                Image(systemName: "plus.circle")
                            })
                            .padding(.trailing, screenWidth * 0.05)
                            .padding(.bottom, screenHeight * 0.03)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(.system(size: screenHeight * 0.03))
                            .sheet(isPresented: $shouldPresentImagePicker) {
                                ImagePicker(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, selectedImage: self.$image)
                                    .onDisappear {
                                        profileViewModel.firebaseStorageManager.uploadImageToStorage(image: image, userID: profileViewModel.profile!.id) { uploadedImageURL in
                                            if profileViewModel.profile?.photosURLs?.count == 0 || self.profileViewModel.userPicturesView.count == 0 {
                                                profileViewModel.profilePictureChange(imageID: uploadedImageURL, newProfilePicture: PictureView(id: uploadedImageURL, uiImageView: UIImageView(image: image))) {
                                                    print("Successfully set new profile picture.")
                                                }
                                            }
                                            profileViewModel.addImageURLToUserImages(imageURL: uploadedImageURL) {
                                                profileViewModel.addUploadedImageToPhotos(imageURL: uploadedImageURL) {
                                                }
                                            }
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
                        }
                        
                        VStack {
                            HStack {
                                Text(self.profileViewModel.profile!.firstName.capitalized)
                                    .font(.system(size: screenHeight * 0.05, weight: .bold))
                                                            
                                Text(String(self.profileViewModel.profile!.age))
                                    .font(.system(size: screenHeight * 0.037, weight: .light))
                                
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "house.fill")
                                
                                Text(self.profileViewModel.profile!.city.capitalized)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Text("About me:")
                                    .font(.system(size: screenHeight * 0.023, weight: .semibold))
                                
                                Spacer()
                                
                                NavigationLink(destination: SettingsView(profile: profileViewModel), isActive: $shouldPresentSettings) {
                                    Button(action: {
                                        self.shouldPresentSettings = true
                                    }, label: {
                                        HStack {
                                            Image(systemName: "gearshape")
                                            Text("Settings")
                                        }
                                    })
                                    .padding(.trailing, screenWidth * 0.1)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .font(.system(size: screenHeight * 0.025))
                                }
                            }
                            .padding(.top, screenHeight * 0.02)
                            
                            HStack {
                                Text(self.profileViewModel.profile!.bio)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                            }
                            
                            NavigationLink(destination: EditView(profile: profileViewModel), isActive: $editMode) {
                                                            Button(action: {
                                                                withAnimation {
                                                                    editMode.toggle()
                                                                }
                                                            }, label: {
                                                                HStack {
                                                                    Image(systemName: "pencil.circle")
                                                                    Text("Update your profile")
                                                                }
                                                            })
                                                            .padding(.top, screenHeight * 0.03)
                                                            .font(.system(size: screenHeight * 0.02))
                                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                                        }
                            
                        }
                        .padding(.leading)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                        ForEach(self.profileViewModel.userPicturesView) { (userPictureView) in
                            if userPictureView.uiImageView.image != nil {
                                Image(uiImage: userPictureView.uiImageView.image!)
                                    .resizable()
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                    .frame(width: screenWidth * 0.48, height: screenHeight * 0.4)
                                    .onLongPressGesture {
                                        withAnimation {
                                            self.selectedItem = userPictureView
                                        }
                                    }
                                    .actionSheet(item: $selectedItem) { item in
                                        ActionSheet(title: Text("Edit selected"), message: nil, buttons: [
                                            .default(Text("Set as profile picture"), action: {
                                                withAnimation {
                                                    self.profileViewModel.profilePictureChange(imageID: item.id, newProfilePicture: item) {}
                                                }
                                            }),
                                            .destructive(Text("Delete this photo"), action: {
                                                withAnimation {
                                                    self.profileViewModel.deleteUserImage(imageID: item.id) {}
                                                    if self.profileViewModel.getImageIndexFromImageID(imageID: item.id) == self.profileViewModel.getProfilePictureIndex() {
                                                        if (self.profileViewModel.profile?.photosURLs!.count)! >= 1 && self.profileViewModel.userPicturesView.count >= 1 {
                                                            self.profileViewModel.profilePictureChange(imageID: (self.profileViewModel.profile?.photosURLs!.first)!, newProfilePicture: self.profileViewModel.userPicturesView[0]) {}
                                                        } else {
                                                            self.profileViewModel.profilePictureChange(imageID: "nil", newProfilePicture: PictureView(id: "nil", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))) {}
                                                        }
                                                    }
                                                    if (self.profileViewModel.profile?.photosURLs!.count)! <= 1 {
                                                        self.profileViewModel.profilePictureChange(imageID: "nil", newProfilePicture: PictureView(id: "nil", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))) {}
                                                    } else {
                                                        if self.profileViewModel.getImageIndexFromImageID(imageID: item.id) == self.profileViewModel.getProfilePictureIndex() {
                                                            self.profileViewModel.profilePictureChange(imageID: (self.profileViewModel.profile?.photosURLs!.first)!, newProfilePicture: self.profileViewModel.userPicturesView[0]) {}
                                                        }
                                                    }
                                                }
                                            }),
                                            .cancel()
                                        ])
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, screenWidth * 0.005)
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct SettingsView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    
    @StateObject private var sheetManager = SheetManager()
    @State private var shouldPresentActionSheet = false
    
    
    private class SheetManager: ObservableObject {
        enum Sheet {
            case email
            case password
            case logout
            case signout
        }
        
        @Published var showSheet = false
        @Published var whichSheet: Sheet? = nil
    }
    
    
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
                            sheetManager.whichSheet = .email
                            sheetManager.showSheet.toggle()
                        }, label: {
                            Text("Change e-mail address")
                        })
                        
                        Button(action: {
                            sheetManager.whichSheet = .password
                            sheetManager.showSheet.toggle()
                        }, label: {
                            Text("Change password")
                        })
                        
                        Button(action: {
                            sheetManager.whichSheet = .logout
                            shouldPresentActionSheet = true
                        }, label: {
                            Text("Logout")
                                .foregroundColor(.red)
                        })
                        
                        Button(action: {
                            sheetManager.whichSheet = .signout
                            shouldPresentActionSheet = true
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
                
                .sheet(isPresented: $sheetManager.showSheet) {
                    switch sheetManager.whichSheet {
                    case .email:
                        ChangeEmailAddressSheetView(profile: profileViewModel)
                    case .password:
                        ChangePasswordSheetView(profile: profileViewModel)
                    case .signout:
                        DeleteAccountSheetView(profile: profileViewModel)
                    default:
                        Text("No view")
                    }
                }
                .actionSheet(isPresented: $shouldPresentActionSheet) {
                    if sheetManager.whichSheet == .logout {
                        return ActionSheet(title: Text("Logout"), message: Text("Are you sure you want to logout?"), buttons: [
                            .destructive(Text("Logout"), action: {
                                profileViewModel.session.signOut()
                             }),
                            .cancel()
                        ])
                    } else {
                        return ActionSheet(title: Text("Delete Account"), message: Text("Are you sure you want to delete your account? All data will be lost."), buttons: [
                            .destructive(Text("Delete my account"), action: {
                                sheetManager.showSheet.toggle()
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
    @State var country: Country = .poland
    @State var city: City = .łódź
    @State var language: Language = .polish
    private var preferenceValues = ["Man", "Woman", "Both"]
    
    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            Form {
                Section(header: Text("First Name")) {
                    TextField(profileViewModel.profile!.firstName, text: $firstName)
                }
                
                Section(header: Text("Last Name")) {
                    TextField(profileViewModel.profile!.lastName, text: $lastName)
                }
                
                Section(header: Text("Bio")) {
                    TextEditor(text: $bio)
                }
                
                Section(header: Text("Country")) {
                    Picker("Country", selection: $country) {
                        ForEach(Country.allCases) { country in
                            Text(country.rawValue.capitalized).tag(country)
                        }
                    }
                }
                
                Section(header: Text("City")) {
                    Picker("City", selection: $city) {
                        ForEach(City.allCases) { city in
                            Text(city.rawValue.capitalized).tag(city)
                        }
                    }
                }
                
                Section(header: Text("Language")) {
                    Picker("Language", selection: $language) {
                        ForEach(Language.allCases) { language in
                            Text(language.rawValue.capitalized).tag(language)
                        }
                    }
                }
                
                Section(header: Text("Preference")) {
                    Picker("preference", selection: $preference) {
                        ForEach(preferenceValues, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationBarTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button(action: {
                    withAnimation {
                        if profileViewModel.firstNameChange(firstName: firstName) {
                            profileViewModel.firestoreManager.editUserFirstNameInDatabase(firstName: firstName) {}
                        }
                        if profileViewModel.lastNameChange(lastName: lastName) {
                            profileViewModel.firestoreManager.editUserLastNameInDatabase(lastName: lastName) {}
                        }
                        if profileViewModel.bioChange(bio: bio) {
                            profileViewModel.firestoreManager.editUserBioInDatabase(bio: bio) {}
                        }
                        if profileViewModel.countryChange(country: country.rawValue) {
                            profileViewModel.firestoreManager.editUserCountryInDatabase(country: country.rawValue) {}
                        }
                        if profileViewModel.cityChange(city: city.rawValue) {
                            profileViewModel.firestoreManager.editUserCityInDatabase(city: city.rawValue) {}
                        }
                        if profileViewModel.languageChange(language: language.rawValue) {
                            profileViewModel.firestoreManager.editUserLanguageInDatabase(language: language.rawValue) {}
                        }
                        if profileViewModel.preferenceChange(preference: preference) {
                            profileViewModel.firestoreManager.editUserPreferenceInDatabase(preference: preference) {}
                        }
                        
                        profileViewModel.fetchData() {
                            self.presentationMode.wrappedValue.dismiss()
                        }
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
                            profileViewModel.deleteUserData() {
                                profileViewModel.session.deleteUser(email: email, password: password) {
                                    print("Successfully deleted user.")
                                }
                            }
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


struct ChangeEmailAddressSheetView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var oldEmail = ""
    @State private var password = ""
    @State private var newEmail = ""
    
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
                        Section(footer: Text("Before you change your e-mail address please provide your login credentials to confirm it is really you.")) {
                            TextField("Old e-mail address", text: $oldEmail)
                            SecureField("Password", text: $password)
                            TextField("New e-mail address", text: $newEmail)
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            presentationMode.wrappedValue.dismiss()
                            profileViewModel.emailAddressChange(oldEmailAddress: oldEmail, password: password, newEmailAddress: newEmail) {}
                        }
                    }, label: {
                        Text("Change e-mail address")
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


struct ChangePasswordSheetView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var email = ""
    @State private var oldPassword = ""
    @State private var newPassword = ""
    
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
                        Section(footer: Text("Before you change your password please provide your login credentials to confirm it is really you.")) {
                            TextField("E-mail", text: $email)
                            SecureField("Old password", text: $oldPassword)
                            SecureField("New password", text: $newPassword)
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            presentationMode.wrappedValue.dismiss()
                            profileViewModel.passwordChange(emailAddress: email, oldPassword: oldPassword, newPassword: newPassword) {}
                        }
                    }, label: {
                        Text("Change password")
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
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                ProfileView(profile: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                SettingsView(profile: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                EditView(profile: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
