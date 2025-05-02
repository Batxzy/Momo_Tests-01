//
//  Gallery2tests.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 01/05/25.
//

import SwiftUI


struct GalleryPageView3: View {

    let imageName: String

    // Gesture States (Automatically Reset)
    @GestureState private var gestureMagnification: CGFloat = 1.0
    @GestureState private var gestureRotationAngle: Angle = .zero
    @GestureState private var gestureDragOffset: CGSize = .zero

    // State for Double Tap Reset Anchor
    @State private var scaleAnchor: CGFloat = 1.0
    @State private var offsetAnchor: CGSize = .zero
    @State private var rotationAnchor: Angle = .zero

    // Computed Properties for Live Values
    private var currentScale: CGFloat { gestureMagnification * scaleAnchor }
    private var currentRotation: Angle { gestureRotationAngle + rotationAnchor }
    private var currentOffset: CGSize {
        let rotatedOffset = gestureDragOffset.rotated(by: -currentRotation)
        return CGSize(width: offsetAnchor.width + rotatedOffset.width,
                      height: offsetAnchor.height + rotatedOffset.height)
    }

    // Reset Function for Double Tap with Smoother Animation
    private func resetImageStateWithAnimation() {
        // Define the smoother, longer spring animation for the reset
        // Increased response time, adjusted damping for smoothness
        let resetSpring = Animation.spring(response: 0.55, dampingFraction: 0.7, blendDuration: 12)

        withAnimation(resetSpring) {
            scaleAnchor = 1.0
            offsetAnchor = .zero
            rotationAnchor = .zero
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let viewSize = geometry.size
            Image(imageName)
                .resizable()
                .scaledToFit()
                .scaleEffect(currentScale)
                .rotationEffect(currentRotation)
                .offset(currentOffset)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(26)
            
                .contentShape(Rectangle())

                // --- Gestures ---
                .onTapGesture(count: 2) {
                    resetImageStateWithAnimation() // Use the animated reset function
                }
                .simultaneousGesture(dragGesture(viewSize: viewSize))
                .simultaneousGesture(magnificationGesture())
                .simultaneousGesture(rotationGesture())
        }
        .clipped()
        // Apply the same smoother spring animation when @GestureState variables reset
        .animation(.spring(.smooth), value: gestureMagnification)
        .animation(.spring(.smooth), value: gestureRotationAngle)
        .animation(.spring(.smooth), value: gestureDragOffset)
    }

    // --- Gesture Definitions (Unchanged from previous version) ---

    private func magnificationGesture() -> some Gesture {
        MagnifyGesture()
            .updating($gestureMagnification) { value, state, _ in state = value.magnification }
            .onChanged { _ in scaleAnchor = 1.0 } // Keep anchor at identity
    }

    private func rotationGesture() -> some Gesture {
        RotateGesture()
            .updating($gestureRotationAngle) { value, state, _ in state = value.rotation }
            .onChanged { _ in rotationAnchor = .zero } // Keep anchor at identity
    }

    private func dragGesture(viewSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($gestureDragOffset) { value, state, _ in
                if abs(currentScale - 1.0) > 0.05 { // Only drag if scaled
                    state = value.translation
                } else {
                    state = .zero
                }
            }
            .onChanged { _ in offsetAnchor = .zero } // Keep anchor at identity
    }
}



struct ImageGalleryView3: View {

    let allImageNames: [String]
    let selectedImageName: String
    var namespace: Namespace.ID

    @State private var selectedIndex: Int

    @Environment(\.dismiss) private var dismiss

    init(allImageNames: [String], selectedImageName: String, namespace: Namespace.ID) {
        self.allImageNames = allImageNames
        self.selectedImageName = selectedImageName
        self.namespace = namespace
        _selectedIndex = State(initialValue: allImageNames.firstIndex(of: selectedImageName) ?? 0)
    }

    private var currentImageName: String { allImageNames[selectedIndex] }

    var body: some View {
           ZStack {
               Color.black
                   .ignoresSafeArea()

               VStack(spacing: 0) { // Use spacing 0 and control gaps with padding

                   // Button Row: Aligned to the top-right
                   HStack {
                       Spacer() // Pushes button to the trailing edge
                       Button {
                           dismiss()
                       } label: {
                           Image(systemName: "xmark.circle.fill")
                               .font(.largeTitle) // Adjust size if needed
                               // Modern foregroundStyle for two-tone symbols
                               .foregroundStyle(.white, .black.opacity(0.6))
                               .padding(8) // Internal padding for easier tapping
                       }
                   }
                   .debugStroke()
                   
                   // TabView below the button
                   TabView(selection: $selectedIndex.animation(.smooth)) {
                       ForEach(allImageNames.indices, id: \.self) { index in
                           GalleryPageView(imageName: allImageNames[index])
                               .tag(index)
                       }
                   }
                   .tabViewStyle(.page(indexDisplayMode: .automatic))
                   .ignoresSafeArea(edges: .bottom)
                   .debugStroke()

               }

           }
           .toolbar(.hidden, for: .navigationBar)
           .statusBar(hidden: true)
       }
}


struct GridItemView3: View {
    let imageName: String
    
    var body: some View {
        ZStack {
            Color.secondary.opacity(0.1)
            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(8)
        }
        .aspectRatio(1.0, contentMode: .fit)
        .cornerRadius(8)
    }
}

struct Galleryviewtests3: View {
    @Namespace private var gridItemTransition
    @Binding var path: NavigationPath
       let imageNames = ["rectangle33","rectangle35","Shinji","rectangle1","rectangle2","rectangle3"]

       private let columns: [GridItem] = [
           GridItem(.flexible(), spacing: 20),
           GridItem(.flexible(), spacing: 20)
       ]

       var body: some View {
           ScrollView {
                       LazyVGrid(columns: columns, spacing: 15) { // Adjust spacing
                           ForEach(imageNames, id: \.self) { name in
                               // Use a Button to trigger navigation path change
                               Button {
                                   // Append the specific image detail target to the main path
                                   path.append(NavigationTarget.imageDetail(
                                       allNames: imageNames,
                                       selectedName: name,
                                       namespace: gridItemTransition // Pass the namespace
                                   ))
                               } label: {
                                   GridItemView(imageName: name)
                                       // Link this source view using its 'name' for the transition
                                       .matchedTransitionSource(id: name, in: gridItemTransition)
                               }
                               .buttonStyle(.plain) // Use plain style to avoid default button appearance
                           }
                       }
                       .padding() // Padding for the grid content
                   }
       }
}


struct Galleryview3: View {
    @Environment(LevelManager.self) private var levelManager
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            
            VStack(spacing: 20){
                 
                Text("Galeria")
                    .font(.Patrick60)
                    .frame(maxHeight: 50)
                
                Galleryview3(path: $path)

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
                    
                    .navigationDestination(for: NavigationTarget.self) { target in
                         switch target {
                         case .imageDetail(let names, let selected, let ns):
                              ImageGalleryView(
                                  allImageNames: names,
                                  selectedImageName: selected,
                                  namespace: ns
                              )
                              .navigationTransition(
                                  .zoom(sourceID: selected, in: ns) //
                              )
                             
                
                              .navigationBarBackButtonHidden(true) //
                         default:
                              Text("Preview: Unexpected Navigation Target")
                         }
                    }
            }
            .environment(previewLevelManager)
        }
    }
    return GalleryviewPreviewContainer()
}

