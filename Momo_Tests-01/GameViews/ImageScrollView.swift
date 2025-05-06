//
//  ImageScrollView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//

import SwiftUI

struct ImageScrollView: View {

//MARK: - variables y setup
    @Environment(LevelManager.self) private var levelManager
    @State var didTap: Bool = false
    
    public var images: [Image]
    
    private let imageHeight: CGFloat = 689
    private let imageWidth: CGFloat = 330
    
    
//MARK: - view
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                
                    LazyVStack(spacing: 35) {
                        
                        ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: imageWidth, height: imageHeight)
                                .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
                        }
                        
                        HStack {
                            Spacer()
                            
                            CustomButtonView(title: "siguiente") {
                                levelManager.completeLevel()
                            }
                    }
                            .frame(width: imageWidth)
                }
                
            }
            
        }
    }
}

#Preview {
    ImageScrollView(images: Scroll_2_4)
        .environment(LevelManager())
}
