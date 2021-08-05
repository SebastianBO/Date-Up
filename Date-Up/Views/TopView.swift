//
//  TopView.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 05/08/2021.
//

import SwiftUI

struct TopView: View {
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            Text("Date-Up!")
                .padding(.top, screenHeight * 0.05)
                .font(.system(size: screenHeight * 0.07))
                .background(Rectangle()
                                .foregroundColor(.red)
                                .frame(width: screenWidth))
                .frame(width: screenWidth)
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
