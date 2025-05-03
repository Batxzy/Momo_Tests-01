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
                // Locked state with blur, grayscale and lock icon
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .blur(radius: 4)
                    .grayscale(0.9)
                    .overlay(
                        Image(systemName: "lock.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .circular)
                .stroke(isUnlocked ? Color.primary : Color.gray.opacity(0.5), lineWidth: 5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
    }
}

// MARK: - View grid
struct GalleryviewGrid: View {
    @Namespace private var gridItemTransition
    @Binding var path: NavigationPath
    @Environment(LevelManager.self) private var levelManager

    // List of image names to display
    let imageNames = ["rectangle33", "rectangle35", "Shinji", "rectangle1", "rectangle2", "rectangle3", "wide"]

    // Configuration columns
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 17),
        GridItem(.flexible(), spacing: 17)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 17) {
                ForEach(imageNames, id: \.self) { name in
                    let isUnlocked = name.isUnlocked(levelManager: levelManager)
                    
                    Button {
                        // Only navigate if unlocked
                        if isUnlocked {
                            // Filter the image names to only include unlocked ones
                            let unlockedImages = imageNames.filter { $0.isUnlocked(levelManager: levelManager) }
                            
                            path.append(NavigationTarget.imageDetail(
                                allNames: unlockedImages,
                                selectedName: name,
                                namespace: gridItemTransition
                            ))
                        } else {
                            // Haptic feedback for locked items
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                    } label: {
                        GridItemView(imageName: name, isUnlocked: isUnlocked)
                            .matchedTransitionSource(id: name, in: gridItemTransition)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isUnlocked)
                }
            }
            .padding()
        }
    }
}

// MARK: - Main Gallery View
struct Galleryview: View {
    @Environment(LevelManager.self) private var levelManager
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text("Galeria")
                    .font(.Patrick60)
                    .frame(maxHeight: 50)
                
                // Grid view of images
                GalleryviewGrid(path: $path)
            }
            
            // Custom button to return
            CustomButtonView(title: "Atrás") {
                path.removeLast()
            }
        }
        .padding(20)
    }
}

// MARK: - preview
#Preview {
    struct GalleryviewPreviewContainer: View {
        @State private var previewPath = NavigationPath()
        @State private var previewLevelManager = LevelManager()

        var body: some View {
            NavigationStack(path: $previewPath) {
                Galleryview(path: $previewPath)
                    .navigationDestination(for: NavigationTarget.self) { target in
                        switch target {
                        case .imageDetail(let names, let selected, let ns):
                            ImageGalleryView(
                                allImageNames: names,
                                selectedImageName: selected,
                                namespace: ns
                            )
                            .navigationTransition(
                                .zoom(sourceID: selected, in: ns)
                            )
                            .navigationBarBackButtonHidden(true)
                        default:
                            Text("Preview: Unexpected Navigation Target")
                        }
                    }
            }
            .environment(previewLevelManager)
            .onAppear {
                // For preview, mark first chapter as completed to show some unlocked items
                if !previewLevelManager.chapters.isEmpty {
                    for i in 0..<previewLevelManager.chapters[0].levels.count {
                        previewLevelManager.chapters[0].levels[i].isCompleted = true
                    }
                }
            }
        }
    }
    return GalleryviewPreviewContainer()
}
