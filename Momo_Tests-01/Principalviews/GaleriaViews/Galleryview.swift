//
//  Galleryview.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//

import SwiftUI


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


