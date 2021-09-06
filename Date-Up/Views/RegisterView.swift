//
//  RegisterView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import SwiftUI

struct RegisterView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birthDate = Date()
    @State private var age = 0
    private var preferenceValues = ["Men", "Women", "Both"]
    private var genderValues = ["Man", "Woman"]
    @State private var preference = ""
    @State private var gender = ""
    @State private var email = ""
    @State private var password = ""
    @State var country: Country = .poland
    @State var city: City = .łódź
    @State var language: Language = .polish
    private let textFieldColor = Color("TextFieldsColor")
    @State private var switchToLoginView = false
    @State private var signUpButtonClicked = false
    @ObservedObject var sessionStore = SessionStore()
    @State private var correctData = false
    
    private let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 1900, month: 1, day: 1)
        let endComponents = DateComponents(year: calendar.dateComponents([.year], from: calendar.date(byAdding: .year, value: -18, to: Date()) ?? Date()).year, month: calendar.dateComponents([.month], from: calendar.date(byAdding: .year, value: -18, to: Date()) ?? Date()).month, day: calendar.dateComponents([.day], from: calendar.date(byAdding: .year, value: -18, to: Date()) ?? Date()).day)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if switchToLoginView {
                withAnimation {
                    LoginView()
                }
            } else {
                VStack(spacing: screenHeight * -0.89) {
                    TopView()
                        .frame(width: screenWidth, height: screenHeight)
                
                    NavigationView {
                        ScrollView(.vertical) {
                            Form {
                                Section(header: Text("Personal Information"), footer: signUpButtonClicked ? displayPersonalInformationAndPreferenceErrors() : nil) {
                                    TextField("First Name", text: $firstName)
                                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                                    
                                    TextField("Last Name", text: $lastName)
                                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                                    
                                    DatePicker("Birth Date", selection: $birthDate, in: dateRange, displayedComponents: [.date])
                                    
                                    Picker("Country", selection: $country) {
                                        ForEach(Country.allCases) { country in
                                            Text(country.rawValue.capitalized).tag(country)
                                        }
                                    }
                                    
                                    Picker("City", selection: $city) {
                                        ForEach(City.allCases) { city in
                                            Text(city.rawValue.capitalized).tag(city)
                                        }
                                    }
                                    
                                    Picker("Language", selection: $language) {
                                        ForEach(Language.allCases) { language in
                                            Text(language.rawValue.capitalized).tag(language)
                                        }
                                    }
                                }
                                
                                Section(header: Text("Account Credentials"), footer: signUpButtonClicked ? displayCredentialsErrors() : nil) {
                                    TextField("E-mail", text: $email)
                                    
                                    SecureField("Password", text: $password)
                                }
                                
                                Section(header: Text("Preference"), footer: Text("The preference option is used to show you only the people of gender of your preference")) {
                                    Picker("preference", selection: $preference) {
                                        ForEach(preferenceValues, id: \.self) {
                                            Text($0)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                                
                                Section(header: Text("Gender")) {
                                    Picker("gender", selection: $gender) {
                                        ForEach(genderValues, id: \.self) {
                                            Text($0)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                            }
                            .frame(width: screenWidth, height: screenHeight * 0.72)
                            
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        signUpButtonClicked = true
                                            
                                        if checkDataIsCorrect() {
                                            sessionStore.signUp(firstName: firstName, lastName: lastName, birthDate: birthDate, country: country.rawValue, city: city.rawValue, language: language.rawValue, email: email, password: password, preference: preference, gender: gender)
                                        }
                                    }
                                }, label: {
                                    Text("Register")
                                })
                                .frame(width: screenWidth * 0.4, height: screenHeight * 0.08)
                                            .background(Color.green)
                                            .cornerRadius(15.0)
                                
                                Button(action: {
                                    withAnimation {
                                        switchToLoginView.toggle()
                                    }
                                }, label: {
                                    Text("Back")
                                })
                                .frame(width: screenWidth * 0.4, height: screenHeight * 0.08)
                                            .background(Color.green)
                                            .cornerRadius(15.0)
                            }
                            .padding(.bottom, screenHeight * 0.15)
                            .frame(width: screenWidth, height: screenHeight * 0.2)
                            .font(.system(size: screenHeight * 0.026))
                            .foregroundColor(.white)
                            .padding()
                        }
                        .navigationBarTitle("Registration Form", displayMode: .inline)
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private func displayPersonalInformationAndPreferenceErrors() -> Text {
        if !checkFieldsNotEmpty() {
            return Text("Please fill in all data including your preference and gender").foregroundColor(.red)
        } else {
            return Text("")
        }
    }
    
    private func displayCredentialsErrors() -> Text {
        let emailError = String("Please make sure the email is correct.\n")
        let passwordError = String("Please make sure your password is at least 8 characters long and contains a number.\n")
        
        if !checkEmail() && !checkPassword() {
            return Text(emailError + passwordError).foregroundColor(.red)
        } else if !checkEmail() {
            return Text(emailError).foregroundColor(.red)
        } else if !checkPassword() {
            return Text(passwordError).foregroundColor(.red)
        } else {
            return Text("")
        }
    }
    
    private func checkFieldsNotEmpty() -> Bool {
        if firstName.isEmpty || lastName.isEmpty || preference.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    private func checkEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    private func checkPassword() -> Bool {
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    private func checkDataIsCorrect() -> Bool {
        if checkFieldsNotEmpty() && checkEmail() && checkPassword() {
            return true
        } else {
            return false
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                RegisterView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}


