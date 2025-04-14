//
//  ChapterMenu.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//

import SwiftUI

struct ChapterMenu: View {
    var body: some View {
        VStack(spacing: 32) {
            Text("Capitulo 1")
                .font(.system(size: 32, weight: .medium))
            Text("Capitulo 2")
                .font(.system(size: 32, weight: .medium))
            Text("Capitulo 3")
                .font(.system(size: 32, weight: .medium))
        }
       
    }
}

#Preview {
    ChapterMenu()
}
