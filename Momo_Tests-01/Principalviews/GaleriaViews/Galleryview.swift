//
//  Galleryview.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//

import SwiftUI

struct GridItemView: View {
    let imageName: String
    let isUnlocked: Bool

    var body: some View {
        ZStack {
            Color.white
            if isUnlocked {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
            } else {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .blur(radius: 3)
                    .grayscale(1)
                    .opacity(isUnlocked ? 1.0 : 0.2)
                    .overlay(
                        Image(systemName: "lock.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.black)
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .circular)
                .stroke(isUnlocked ? Color.black : Color.gray.opacity(0.2), lineWidth: 5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
        
    }
}

// MARK: - View grid
struct GalleryviewGrid: View {
    @Namespace private var gridItemTransition
    @Binding var path: NavigationPath
    @Environment(LevelManager.self) private var levelManager

    // Configuration columns
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 17),
        GridItem(.flexible(), spacing: 17)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 17) {
                ForEach(galleryItems, id: \.id) { item in
                    let isUnlocked = item.isUnlocked(levelManager: levelManager)

                    Button {
                        if isUnlocked {
                            let unlockedItems = galleryItems.filter { $0.isUnlocked(levelManager: levelManager) }
                            let unlockedImageNames = unlockedItems.map { $0.imageName }
                            
                            path.append(NavigationTarget.imageDetail(
                                allNames: unlockedImageNames,
                                selectedName: item.imageName,
                                namespace: gridItemTransition
                            ))
                        }
                    } label: {
                        GridItemView(imageName: item.imageName, isUnlocked: isUnlocked)
                            .contentShape(Rectangle())
                            .matchedTransitionSource(id: item.imageName, in: gridItemTransition)
                    }
                    .buttonStyle(.plain)
                    
                    
                }
            }
            
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Main Gallery View

struct Galleryview: View {
    @Binding var path: NavigationPath

    var body: some View {
        VStack(spacing:0) { // Keep spacing 0 if desired
            // Container for title and grid
            VStack(spacing: 10) { // Use original spacing if preferred
                Text("Galeria")
                    .font(.Patrick60)
                    .frame(maxHeight: 60)

                // Grid view of images - Apply modifier HERE
                GalleryviewGrid(path: $path)
                .fadingEdgeGradient( // Use the gradient modifier
                    topHeight: 20,       // Your desired top height
                    bottomHeight: 40,   // Your desired bottom height (e.g., 4 * 40)
                    color: .white,       // Match background
                    solidStop: 0.4      // Control fade point (optional)
                )
            }
            
            CustomButtonView(title: "Atrás") {
                if !path.isEmpty {
                   path.removeLast()
                }
            }
            .padding(.bottom ,30)
        }
        .padding(20)
        .background(.white)
        .navigationBarHidden(true)
    }
}


// MARK: - preview
#Preview {
    // Preview Container using the new structure
    struct GalleryviewPreviewContainer: View {
        @State private var previewPath = NavigationPath()
        // Use a State var for the manager in preview
        @State private var previewLevelManager = LevelManager()

        var body: some View {
            // Use NavigationStack for preview consistency
            NavigationStack(path: $previewPath) {
                Galleryview(path: $previewPath)
                    // Add navigation destinations needed for the preview flow
                    .navigationDestination(for: NavigationTarget.self) { target in
                        switch target {
                        case .imageDetail(let names, let selected, let ns):
                            // Ensure ImageGalleryView initializer matches
                            ImageGalleryView(
                                allImageNames: names,
                                selectedImageName: selected,
                                namespace: ns
                            )
                            // Apply transitions and modifiers as in the main app
                            .navigationTransition(.zoom(sourceID: selected, in: ns))
                            .navigationBarBackButtonHidden(true)
                            .toolbar(.hidden, for: .navigationBar) // Hide toolbar for detail view
                        default:
                            Text("Preview: Unexpected Navigation Target")
                        }
                    }
            }
            // Provide the preview LevelManager to the environment
            .environment(previewLevelManager)
            .onAppear {
                 // Simulate unlocking based on the galleryItems structure
                 // Example: Unlock chapter 0 (required for first two items)
                 let chapterIndexToUnlock = 0
                
                 if previewLevelManager.chapters.indices.contains(chapterIndexToUnlock) {
                     // Mark all levels in that chapter as completed
                     for i in 0..<previewLevelManager.chapters[chapterIndexToUnlock].levels.count {
                         previewLevelManager.chapters[chapterIndexToUnlock].levels[i].isCompleted = true
                     }
                     // Optionally, explicitly mark the chapter as unlocked if needed by your logic
                     // previewLevelManager.chapters[chapterIndexToUnlock].isUnlocked = true
                     print("Preview: Unlocked items for Chapter \(chapterIndexToUnlock + 1)")
                 } else {
                     print("Preview: Chapter \(chapterIndexToUnlock + 1) not found in LevelManager.")
                 }
            }
        }
    }
    return GalleryviewPreviewContainer()
}
