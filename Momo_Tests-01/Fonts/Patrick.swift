//
//  Patrick.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 30/04/25.
//

import SwiftUI

extension View {
    func debugStroke(_ color: Color = .red, lineWidth: CGFloat = 1) -> some View {
        self.overlay(
            Rectangle()
                .stroke(color, lineWidth: lineWidth)
        )
    }
}

extension Font {
    static let Patrick32 = Font.custom("PatrickHand-Regular", size: 32)
    static let Patrick48 = Font.custom("PatrickHand-Regular", size: 48)
    static let Patric29 = Font.custom("PatrickHand-Regular", size: 29)
    static let Patrick60 = Font.custom("PatrickHand-Regular", size: 60)
}

