//
//  ToggleView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 16/04/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func invertedIf(_ condition: Bool) -> some View {
        if condition {
            self.colorInvert()
        } else {
            self
        }
    }
}

struct ToggleView: View {
    @State private var darkMode = false
    
    var body: some View {
        ZStack {
            // Background with smooth transition
            (darkMode ? Color.white : Color.black)
                .ignoresSafeArea()
                
            
            VStack {
                Spacer()
                
                Image("Shinji2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .background {
                        (darkMode ? Color.white : Color.black)
                           
                    }
                    .invertedIf(darkMode)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                   
                
                Spacer()
                
                // Centered toggle with container for better visibility
                VStack {
                    Toggle("", isOn: $darkMode)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .tint(.black)
                        .frame(width: 80)
                        .scaleEffect(1.2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(darkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(height: 60)
                        .frame(maxWidth: 200)
                }
                
                Spacer()
            }
            .padding()
        }
        // Apply transition to all elements that change with dark mode
        .preferredColorScheme(darkMode ? .dark : .light)
    }
}

#Preview {
    ToggleView()
}
