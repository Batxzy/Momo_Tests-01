//
//  DialogueViewWide.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 02/05/25.
//
import SwiftUI

struct DialogueViewWide: View {

    let imageName: String
    let frameGeometry: GeometryProxy

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .transition(.opacity)
            .frame(width: frameGeometry.size.width, height: 250)
            .clipped()
            .position(x: frameGeometry.size.width / 2, y: 17)
            .id("dialogue-\(imageName)")
    }
}

#Preview{
   
}
