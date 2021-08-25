//
//  ContentView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var sessionStore = SessionStore()
    
    init() {
        sessionStore.listen()
    }
    
    var body: some View {
        LoggedUserView()
            .fullScreenCover(isPresented: $sessionStore.isAnonymous, content: {
                LoginView()
            })
            .ignoresSafeArea(.keyboard)
    }
}

extension UINavigationController {
    // Remove back button text
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            ContentView().preferredColorScheme($0)
        }
    }
}
