//
//  RegisterView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import SwiftUI

struct RegisterView: View {
    @State private var name = ""
    @State private var lastName = ""
    @State private var birthDate = Date()
    @State private var age = 0
    private var preferenceValues = ["Men", "Women", "Both"]
    @State private var preference = ""
    @State private var email = ""
    @State private var password = ""
    private let textFieldColor = Color("TextFieldsColor")
    @State private var switchToLoginView = false
    @ObservedObject var sessionStore = SessionStore()
    
    private let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        let endComponents = DateComponents(year: 2021, month: 12, day: 31, hour: 23, minute: 59, second: 59)
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
                        TextField("name", text: $name)
                        
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
                        Button(action: {
                            withAnimation {
                                sessionStore.signUp(email: email, password: password)
                                switchToLoginView.toggle()
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
