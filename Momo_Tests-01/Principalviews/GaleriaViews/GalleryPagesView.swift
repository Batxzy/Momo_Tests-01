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

/// A ViewModifier that overlays fading gradients at the top and/or bottom edges.
struct FadingEdgeGradientModifier: ViewModifier {
    /// The default vertical height of the fade effect area if specific heights aren't provided.
    var defaultHeight: CGFloat
    /// Specific height for the top fade area. Overrides defaultHeight if set.
    var topHeight: CGFloat? = nil
    /// Specific height for the bottom fade area. Overrides defaultHeight if set.
    var bottomHeight: CGFloat? = nil
    /// The color to fade from (solid part of the gradient).
    var color: Color = .white
    /// The location where the color starts becoming fully solid (0.0 to 1.0).
    /// Adjust this to control how quickly the fade happens. 0.0 means it starts fading immediately.
    var solidStopLocation: CGFloat = 0.34 // Default based on your example

    // Calculate effective heights, ensuring they are not negative
    private var effectiveTopHeight: CGFloat { max(0, topHeight ?? defaultHeight) }
    private var effectiveBottomHeight: CGFloat { max(0, bottomHeight ?? defaultHeight) }

    // Define gradient stops based on parameters
    private var topGradientStops: [Gradient.Stop] {
        [
            .init(color: color, location: 0.0), // Start solid at the very top
            .init(color: color, location: 1.0 - solidStopLocation), // Become solid by this point (inverted for top)
            .init(color: color.opacity(0), location: 1.0) // Fully transparent at the bottom of the gradient frame
        ]
    }

    private var bottomGradientStops: [Gradient.Stop] {
         [
             .init(color: color.opacity(0), location: 0.0), // Start transparent at the top of the gradient frame
             .init(color: color, location: solidStopLocation), // Become solid by this point
             .init(color: color, location: 1.0) // End solid at the very bottom
         ]
     }


    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                // Only add top gradient if height > 0
                if effectiveTopHeight > 0 {
                    LinearGradient(
                        stops: topGradientStops,
                        // Gradient goes from top (solid) to bottom (transparent)
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: effectiveTopHeight) // Control the height of the gradient area
                    .allowsHitTesting(false) // Let touches pass through
                    .ignoresSafeArea(edges: .top) // Allow extending into the safe area
                }
            }
            .overlay(alignment: .bottom) {
                 // Only add bottom gradient if height > 0
                if effectiveBottomHeight > 0 {
                     LinearGradient(
                         stops: bottomGradientStops,
                         // Gradient goes from top (transparent) to bottom (solid)
                         startPoint: .top,
                         endPoint: .bottom
                     )
                    .frame(height: effectiveBottomHeight) // Control the height of the gradient area
                    .allowsHitTesting(false)
                    .ignoresSafeArea(edges: .bottom) // Allow extending into the safe area
                }
            }
    }
}

// MARK: - View Extension for Convenience
extension View {
    /// Applies fading gradients to the top and/or bottom edges of the view.
    /// - Parameters:
    ///   - height: The default height for top and bottom edges if specific heights aren't provided.
    ///   - topHeight: Specific height for the top edge fade. Overrides `height`.
    ///   - bottomHeight: Specific height for the bottom edge fade. Overrides `height`.
    ///   - color: The color to fade from. Defaults to `.white`.
    ///   - solidStop: The relative location (0-1) where the gradient becomes fully solid. Defaults to 0.34.
    /// - Returns: A view with the fading gradients applied.
    func fadingEdgeGradient(
        height: CGFloat = 60, // Default height if others are nil
        topHeight: CGFloat? = nil,
        bottomHeight: CGFloat? = nil,
        color: Color = .white,
        solidStop: CGFloat = 0.34
    ) -> some View {
        self.modifier(FadingEdgeGradientModifier(
            defaultHeight: height,
            topHeight: topHeight,
            bottomHeight: bottomHeight,
            color: color,
            solidStopLocation: solidStop
        ))
    }
}

let galleryItems: [ImageGalleryItem] = [
    ImageGalleryItem(imageName: "rectangle33", requiredChapterIndex: 0, title: "Chapter 1 - Image 1"),
    ImageGalleryItem(imageName: "rectangle35", requiredChapterIndex: 0, title: "Chapter 1 - Image 2"), // Corrected imageName from duplicate
    ImageGalleryItem(imageName: "Shinji", requiredChapterIndex: 1, title: "Chapter 2 - Image 1"),
    ImageGalleryItem(imageName: "rectangle1", requiredChapterIndex: 1, title: "Chapter 2 - Image 2"),
    ImageGalleryItem(imageName: "rectangle2", requiredChapterIndex: 2, title: "Chapter 3 - Image 1"),
    ImageGalleryItem(imageName: "rectangle3", requiredChapterIndex: 3, title: "Chapter 4 - Image 1"),
    ImageGalleryItem(imageName: "wide", requiredChapterIndex: 3, title: "Chapter 4 - Image 2"), // Added 'wide' based on previous code
    // Add more items as needed
]


struct ImageGalleryItem: Identifiable, Hashable {
    let id = UUID()
    let imageName: String
    let requiredChapterIndex: Int // The chapter index (0-based) that needs to be completed
    let title: String

    func isUnlocked(levelManager: LevelManager) -> Bool {
        // Check if the required chapter index is valid within the level manager's chapters
        guard levelManager.chapters.indices.contains(requiredChapterIndex) else {
            // Log a warning if the required index is invalid for this item
            print("⚠️ Warning: Required chapter index \(requiredChapterIndex) is out of bounds for gallery item '\(imageName)'. Check galleryItems definition.")
            return false // Chapter index doesn't exist in the loaded chapters
        }

        // Get the specific chapter required to unlock this item
        let requiredChapter = levelManager.chapters[requiredChapterIndex]

        // --- Corrected Logic ---
        // Item is unlocked if and only if all levels in the required chapter are completed.
        let unlocked = requiredChapter.isAllLevelsCompleted

        // Optional: Add logging for easier debugging
        // print("Checking unlock status for '\(title)' (requires chapter \(requiredChapterIndex + 1) completion): \(unlocked)")

        return unlocked
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
