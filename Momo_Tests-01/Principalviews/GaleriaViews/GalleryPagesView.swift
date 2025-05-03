//
//  GalleryPageView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 01/05/25.
//
 
import SwiftUI

extension CGSize {
    func rotated(by angle: Angle) -> CGSize {
        let r = CGFloat(angle.radians)
        let newW = width  * cos(r) - height * sin(r)
        let newH = width  * sin(r) + height * cos(r)
        return CGSize(width: newW, height: newH)
    }
}

extension String {
    // Get required chapter index for unlocking this image
    func requiredChapterIndex() -> Int {
        switch self {
        case "rectangle33", "rectangle35", "Reason":
            return 0 // Chapter 1 images
        case "Shinji", "rectangle1":
            return 1 // Chapter 2 images
        case "rectangle2":
            return 2 // Chapter 3 images
        case "rectangle3", "wide":
            return 3 // Chapter 4 images
        default:
            return 0 // Default to Chapter 1 for unknown images
        }
    }
    
    // Check if image is unlocked based on level manager progress
    func isUnlocked(levelManager: LevelManager) -> Bool {
        let requiredChapter = requiredChapterIndex()
        
        // Check if the required chapter exists
        guard levelManager.chapters.indices.contains(requiredChapter) else {
            return false
        }
        
        // Image is unlocked if required chapter is completed
        let chapter = levelManager.chapters[requiredChapter]
        if chapter.levels.allSatisfy({ $0.isCompleted }) {
            return true
        }
        
        // Also unlock if any later chapter is unlocked
        return levelManager.chapters.indices.contains(requiredChapter + 1) &&
               levelManager.chapters[requiredChapter + 1].isUnlocked
    }
}

struct ImageGalleryItem: Identifiable, Hashable {
    let id = UUID()
    let imageName: String
    let requiredChapterIndex: Int // The chapter that needs to be completed to unlock this image
    let title: String
    
    func isUnlocked(levelManager: LevelManager) -> Bool {
        // Check if the required chapter is completed (all levels in the chapter are completed)
        guard levelManager.chapters.indices.contains(requiredChapterIndex) else {
            return false
        }
        
        let chapter = levelManager.chapters[requiredChapterIndex]
        
        // An item is unlocked if the required chapter is completed or if a later chapter is unlocked
        if chapter.isAllLevelsCompleted {
            return true
        }
        
        // Also unlock if any later chapter is unlocked (meaning the player has progressed past this chapter)
        return levelManager.chapters.indices.contains(requiredChapterIndex + 1) &&
               levelManager.chapters[requiredChapterIndex + 1].isUnlocked
    }
    
    // For Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ImageGalleryItem, rhs: ImageGalleryItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Single page view
struct GalleryPageView: View {
    let imageName: String
    
    // Gesture states for zoom (pinch)
    @GestureState private var gestureScale: CGFloat  = 1.0
    @GestureState private var gestureRotation: Angle = .zero
    
    // Accumulated animated scale and rotation
    @State private var animScale: CGFloat  = 1.0
    @State private var animRotation: Angle = .zero
    
    // Current scale and size
    private var currentScale: CGFloat {
        gestureScale * animScale
    }
    private var currentRotation: Angle {
        gestureRotation + animRotation
    }
    
    // Animation to return
    private let spring = Animation.spring(.smooth)
    
    // Gestures
    private var pinch: some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { final in
                animScale = final
                // Smoothly return to normal scale
                withAnimation(spring) { animScale = 1.0 }
            }
    }
    private var rotate: some Gesture {
        RotationGesture()
            .updating($gestureRotation) { value, state, _ in
                state = value
            }
            .onEnded { final in
                animRotation = final
                // Smoothly return to normal rotation
                withAnimation(spring) { animRotation = .zero }
            }
    }
    
    // MARK: - body
    var body: some View {
        GeometryReader { geo in
            Image(imageName)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.black, lineWidth: 4)
                }
                .scaleEffect(currentScale)
                .rotationEffect(currentRotation)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(26)
                .padding(.bottom, 24)
                // Gestures
                .highPriorityGesture(
                    pinch.simultaneously(with: rotate),
                    including: .gesture
                )
        }
        .clipped()
    }
}

// MARK: - Gallery pages view
struct ImageGalleryView: View {
    // Parameters match what's being passed in NavigationTarget
    let allImageNames: [String]
    let selectedImageName: String
    var namespace: Namespace.ID
    
    @State private var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    // Initialize with the strings directly
    init(allImageNames: [String], selectedImageName: String, namespace: Namespace.ID) {
        self.allImageNames = allImageNames
        self.selectedImageName = selectedImageName
        self.namespace = namespace
        _selectedIndex = State(initialValue: allImageNames.firstIndex(of: selectedImageName) ?? 0)
        
        // Customize the page indicator (UIPageControl)
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.1)
    }
    
    // Currently selected name
    private var currentImageName: String { allImageNames[selectedIndex] }
    
    var body: some View {
        ZStack {
            // White background for the gallery
            Color.white
                .ignoresSafeArea()
            
            // Container gallery and the X
            VStack(spacing: -12) {
                // The X button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 46))
                            .foregroundStyle(.black)
                            .padding(8)
                    }
                }
                .padding(.horizontal, 26)
                
                // The gallery
                TabView(selection: $selectedIndex.animation(.smooth)) {
                    ForEach(allImageNames.indices, id: \.self) { index in
                        GalleryPageView(imageName: allImageNames[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .statusBar(hidden: true)
    }
}

// MARK: - preview
