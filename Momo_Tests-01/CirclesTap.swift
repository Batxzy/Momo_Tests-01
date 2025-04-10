//
//  SwiftUIView.swift
//  b2
//
//  Created by Jose julian Lopez on 06/04/25.
//

import SwiftUI

struct CirclesView: View {
    // Track which circles have been tapped
    @State private var circleTapped = [false, false, false, false]
   
    public var TapCompleted: Bool  {
        for index in 0..<4{
            if !circleTapped[index]{
                return false
            }
        }
        return true
    }
    
    @State private var gameDone: Bool = false
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .frame(width: 50, height: 50)
                
    
                    .animation(.spring (response: 0.3, dampingFraction: 0.4)){
                        $0.scaleEffect(circleTapped[index] ? 1.5 : 1.0)
                    }
                    
                
                    .animation(.easeOut.delay(0.3)){
                        $0.opacity(circleTapped[index] ? 0 : 1)
                    }
                
                    .onTapGesture {
                        
                        circleTapped[index].toggle()
                        if TapCompleted {
                        gameDone = true
                            print(gameDone	)
                    }
                }
            }
        }
        .padding()
    }
}


#Preview {
    CirclesView()
}
