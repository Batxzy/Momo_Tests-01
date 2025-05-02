//
//  GalleryPageView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 01/05/25.
//
 
import SwiftUI

// Una extension para registrar los cambios en la rotacion
extension CGSize {
    func rotated(by angle: Angle) -> CGSize {
        let r = CGFloat(angle.radians)
        let newW = width  * cos(r) - height * sin(r)
        let newH = width  * sin(r) + height * cos(r)
        return CGSize(width: newW, height: newH)
    }
}

//: - fs
struct GalleryPageView: View {
    let imageName: String

    //estos contienen el valor para que swift registre el zoom
    @GestureState private var gestureScale: CGFloat  = 1.0
    @GestureState private var gestureRotation: Angle = .zero

    // variables state para las animaciones
    @State private var animScale: CGFloat  = 1.0
    @State private var animRotation: Angle = .zero

    // propiedades computadas
    private var currentScale: CGFloat {
        gestureScale * animScale
    }
    
    private var currentRotation: Angle {
        gestureRotation + animRotation
    }
    
    //estos controlan la animacion del zoom
    private let spring = Animation.spring(.smooth)
    
    //gestos
    private var pinch: some Gesture {
            MagnificationGesture()
                .updating($gestureScale) { v, s, _ in s = v }
                .onEnded { final in
                    animScale = final
                    withAnimation(spring) { animScale = 1.0 }
                }
        }

    private var rotate: some Gesture {
        RotationGesture()
            .updating($gestureRotation) { v, s, _ in s = v }
            .onEnded { final in
                animRotation = final
                withAnimation(spring) { animRotation = .zero }
            }
    }

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
                .highPriorityGesture(
                    pinch.simultaneously(with: rotate),
                    including: .gesture
                )
        }
        .clipped()
    }
}

struct ImageGalleryView: View {

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
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.1)
    }

    private var currentImageName: String { allImageNames[selectedIndex] }

    var body: some View {
           ZStack {
               Color.white
                   .ignoresSafeArea()

               VStack(spacing: -12) {
                   HStack() {
                       
                       Spacer()
                       
                       Button {
                           dismiss()
                       } label: {
                           Image(systemName: "xmark.circle")
                               .font(.custom("system", size: 46))
                               .foregroundStyle(.black)
                               .padding(8)
                       }
                   }
                   .padding(.horizontal, 26)
                   
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

#Preview {
    struct PreviewWrapper: View {
        @Namespace var galleryNamespace

        var body: some View {
            ImageGalleryView(
                allImageNames: ["rectangle33", "Shinji", "wide"],
                selectedImageName: "sample1",
                namespace: galleryNamespace
            )
        }
    }
    return PreviewWrapper()
}
