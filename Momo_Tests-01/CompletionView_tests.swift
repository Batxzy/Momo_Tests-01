//
//  CompletionView_tests.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 10/04/25.
//

import SwiftUI

struct CompletionView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            
            Text("You've completed all the levels!")
                .font(.title2)
            
            Button(action: {
                // Action to restart game or return to main menu
                // This would interact with your LevelManager
            }) {
                Text("Play Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 30)
        }
        .padding(40)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.3))
    }
}

#Preview {
    CompletionView()
}
