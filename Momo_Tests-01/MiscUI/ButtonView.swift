//
//  ButtonView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 30/04/25.
//

import SwiftUI


struct CustomButtonView: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(title)
                    .font(.Patrick32)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.head)

                Image(systemName: "arrow.right") // Flecha hacia la derecha
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black)
            }
            
            .frame(minWidth: 98 ,maxHeight: 37)
            
            .padding(16)
            
            .background(
                Color.white
                .cornerRadius(10)
            )
            
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 2)
                    .foregroundColor(.black)
            )
        
        }
    }
}


#Preview {
    
            CustomButtonView(title: "fdsfsdfdsfsdffsdf") {
                print("Button tapped!")
            }
}
