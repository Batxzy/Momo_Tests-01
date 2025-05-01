//
//  Galleryview.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//

import SwiftUI

struct Galleryview: View {
    @Environment(LevelManager.self) private var levelManager
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            
            VStack(spacing: 66){
                
                Text("Capítulos")
                    .font(.Patrick60)
                    .frame(maxHeight: 50)
                
                

            }
        }
        .padding(20)
        
        
        
    }
}

#Preview {
    struct GalleryviewPreviewContainer: View {
        @State private var previewPath = NavigationPath()
        @State private var previewLevelManager = LevelManager()

        var body: some View {
            NavigationStack(path: $previewPath) {
                Galleryview(path: $previewPath)
            }
            .environment(previewLevelManager)
        }
    }
    return GalleryviewPreviewContainer()
}
