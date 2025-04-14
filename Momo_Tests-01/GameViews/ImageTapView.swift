//
//  SwiftUIView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//

import SwiftUI

struct ImageTap: View {
    //MARK: - variables y setup
        @Environment(\.levelManager) var levelManager
        @State private var didTap :Bool  = false
        
        public var iulstration: Image
        
        private let ilustrationHeight: CGFloat = 689
        private let ilustrationWidth: CGFloat = 330
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: .all)
            iulstration
                .resizable()
                .scaledToFill()
                .frame(width: ilustrationWidth, height: ilustrationHeight)
                .clipped()
                .onTapGesture {
                    guard !didTap else { return }
                        didTap = true 
                        levelManager.completeLevel()
                }
        }
    }
}

#Preview {
    ImageTap(iulstration: Image("Reason"))
}
