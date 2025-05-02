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

// MARK: - Single page view
struct GalleryPageView: View {
    let imageName: String

    // Estados de los gestos gesto de zoom (pinch)
    @GestureState private var gestureScale: CGFloat  = 1.0
    @GestureState private var gestureRotation: Angle = .zero

    // Escala y rotacion animada acumulada
    @State private var animScale: CGFloat  = 1.0
    @State private var animRotation: Angle = .zero

    // Escala y tamaño actual
    private var currentScale: CGFloat {
        gestureScale * animScale
    }
    private var currentRotation: Angle {
        gestureRotation + animRotation
    }

    // ** Animación para regresar **
    private let spring = Animation.spring(.smooth)

    // Gestos
    private var pinch: some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { final in
                animScale = final
                // Retorna suavemente a escala normal
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
                // Retorna suavemente a rotación normal
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
                // gestos
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

    //parametros
    let allImageNames: [String]
    let selectedImageName: String
    var namespace: Namespace.ID

    @State private var selectedIndex: Int

    @Environment(\.dismiss) private var dismiss

    // Inicializador personalizado para definir el índice seleccionado desde el inicio
    init(allImageNames: [String], selectedImageName: String, namespace: Namespace.ID) {
        self.allImageNames = allImageNames
        self.selectedImageName = selectedImageName
        self.namespace = namespace
        _selectedIndex = State(initialValue: allImageNames.firstIndex(of: selectedImageName) ?? 0)
        // Personaliza el indicador de la página (UIPageControl)
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.1)
    }

    // Nombre de la imagen actualmente seleccionada
    private var currentImageName: String { allImageNames[selectedIndex] }

// MARK: - body
    var body: some View {
        ZStack {
            
            // Fondo blanco para la galería
            Color.white
                .ignoresSafeArea()
            
            //-- contenedor galeria y la x --//
            VStack(spacing: -12) {
                
                //-- la x --//
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

                //-- la galeria--//
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
