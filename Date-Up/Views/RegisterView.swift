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
    @State private var preference = ""
    @State private var email = ""
    @State private var password = ""
    private let textFieldColor = Color("TextFieldsColor")
    @State private var switchToLoginView = false
    @State private var showDataError = false
    @State private var showEmailError = false
    @State private var showPasswordError = false
    @ObservedObject var sessionStore = SessionStore()
    private var newProfile = ProfileViewModel()
    private var correctData = false
    
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
                LoginView()
            } else {
                TopView()
                
                VStack {
                    
                    Group {
                        TextField("first name", text: $firstName)
                        
                        TextField("last name", text: $lastName)
                        
                        DatePicker("birth date", selection: $birthDate, in: dateRange, displayedComponents: [.date])
                            .padding(.trailing, screenWidth * 0.28)
                        
                        TextField("e-mail", text: $email)
                        
                        SecureField("password", text: $password)
                    }
                    .padding()
                    .background(textFieldColor)
                    .cornerRadius(5.0)
                    .padding(.bottom, screenHeight * 0.02)
                    
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
                    
                    VStack (spacing: screenHeight * 0.01) {
                        if showDataError {
                            Text("Please fill in all data!")
                                .foregroundColor(.red)
                        }
                        
                        if showEmailError {
                            Text("Please, write correct email!")
                                .foregroundColor(.red)
                        }
                        if showPasswordError {
                            Text("Make sure your password is 8 characters long, contains at least one number and one special character!")
                                .foregroundColor(.red)
                        }
                        Button(action: {
                            withAnimation {
                                if !checkFieldsNotEmpty(firstName: firstName, lastName: lastName, preference: preference) {
                                    showDataError = true
                                } else {
                                    showDataError = false
                                }
                                
                                if !checkEmail(email: email) {
                                    showEmailError = true
                                } else {
                                    showEmailError = false
                                }
                                    
                                if !checkPassword(password: password) {
                                    showPasswordError = true
                                } else {
                                    showPasswordError = false
                                }
                                    
                                if correctData {
                                    sessionStore.signUp(firstName: firstName, lastName: lastName, birthDate: birthDate, email: email, password: password, preference: preference)
                                    
                                    switchToLoginView.toggle()
                                }
                            }
                        }, label: {
                            Text("Register")
                                .font(.system(size: screenHeight * 0.026))
                                            .foregroundColor(.white)
                                            .padding()
                                .frame(minWidth: screenWidth * 0.4, maxHeight: screenHeight * 0.08)
                                            .background(Color.green)
                                            .cornerRadius(15.0)
                        })
                        
                        Button(action: {
                            withAnimation {
                                switchToLoginView.toggle()
                            }
                        }, label: {
                            Text("Back")
                                .font(.system(size: screenHeight * 0.026))
                                            .foregroundColor(.white)
                                            .padding()
                                .frame(minWidth: screenWidth * 0.4, maxHeight: screenHeight * 0.08)
                                            .background(Color.green)
                                            .cornerRadius(15.0)
                        })
                    }
                    
                }
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.top, screenHeight * 0.15)
                .frame(width: screenWidth)
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

func checkFieldsNotEmpty(firstName: String, lastName: String, preference: String) -> Bool {
    if firstName.isEmpty || lastName.isEmpty || preference.isEmpty {
        return false
    } else {
        return true
    }
}

func checkEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
}

func checkPassword(password: String) -> Bool {
    let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
    return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
}
