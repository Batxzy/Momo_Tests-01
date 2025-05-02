//
//  Galleryview.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
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


struct GridItemView: View {
    let imageName: String

    var body: some View {
        ZStack {
            Color.white
            
            Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .circular)
                            .stroke(Color.primary, lineWidth: 5)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                }
}

struct Galleryviewtests: View {
    @Namespace private var gridItemTransition
    @Binding var path: NavigationPath
       let imageNames = ["rectangle33","rectangle35","Shinji","rectangle1","rectangle2","rectangle3"]

       private let columns: [GridItem] = [
           GridItem(.flexible(), spacing: 17),
           GridItem(.flexible(), spacing: 17)
       ]

       var body: some View {
           ScrollView {
               LazyVGrid(columns: columns, spacing: 17) {
                   ForEach(imageNames, id: \.self) { name in
                       Button {
                           path.append(NavigationTarget.imageDetail(
                               allNames: imageNames,
                               selectedName: name,
                               namespace: gridItemTransition
                           ))
                       } label: {
                           GridItemView(imageName: name)
                               .matchedTransitionSource(id: name, in: gridItemTransition)
                       }
                       .buttonStyle(.plain)
                   }
               }
               .padding()
           }
       }
}


struct Galleryview: View {
    @Environment(LevelManager.self) private var levelManager
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            
            VStack(spacing: 20){
                 
                Text("Galeria")
                    .font(.Patrick60)
                    .frame(maxHeight: 50)
                
                Galleryviewtests(path: $path)

            }
            
            CustomButtonView(title: "atras (temp)") {
                path.removeLast()
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


