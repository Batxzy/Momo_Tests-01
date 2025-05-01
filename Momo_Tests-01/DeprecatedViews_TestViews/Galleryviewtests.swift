//
//  Galleryviewtests.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 30/04/25.
//


import SwiftUI

struct GalleryPageView2: View {
    let imageName: String

    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
            .padding(20)
    }
}

struct ImageGalleryView2: View {
    let allImageNames: [String]
    let selectedImageName: String
    var namespace: Namespace.ID

    @State private var selectedIndex: Int

    init(allImageNames: [String], selectedImageName: String, namespace: Namespace.ID) {
        self.allImageNames = allImageNames
        self.selectedImageName = selectedImageName
        self.namespace = namespace
        _selectedIndex = State(initialValue: allImageNames.firstIndex(of: selectedImageName) ?? 0)
    }

    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(allImageNames.indices, id: \.self) { index in
                GalleryPageView2(imageName: allImageNames[index])
                    // Assign a tag matching the index to each page for selection binding
                    .tag(index)
            }
        }
        // Use page style for swipeable gallery behavior
        .tabViewStyle(.page(indexDisplayMode: .automatic)) // Show page indicator dots
        // Background for the entire gallery area
        .background(Color.black)
        .ignoresSafeArea(edges: .bottom)
    }
}

struct GridItemView2: View {
    let imageName: String
    // Removed namespace and id properties as they are applied *on* the view instance

    var body: some View {
        ZStack {
            Color.secondary.opacity(0.1)
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .padding(8)
        }
        .aspectRatio(1.0, contentMode: .fit)
        .cornerRadius(8)
    }
}

struct Galleryviewtests2: View {
    @Namespace private var gridItemTransition

       let imageNames = [
           "house.fill", "car.fill", "figure.walk", "airplane",
           "gamecontroller.fill", "paintbrush.fill", "camera.fill", "music.note",
           "books.vertical.fill", "folder.fill", "trash.fill", "paperplane.fill"
       ]

       private let columns: [GridItem] = [
           GridItem(.flexible(), spacing: 20),
           GridItem(.flexible(), spacing: 20)
       ]

       var body: some View {
           NavigationStack {
               ScrollView {
                   LazyVGrid(columns: columns, spacing: 20) {
                       ForEach(imageNames, id: \.self) { name in
                           NavigationLink {
                               // ---- Destination Changed ----
                               ImageGalleryView2(
                                   allImageNames: imageNames,    // Pass all names
                                   selectedImageName: name,      // Pass the tapped name
                                   namespace: gridItemTransition // Pass the namespace
                               )
                               // Apply the zoom transition, linking to the tapped grid item 'name'
                               .navigationTransition(
                                   .zoom(sourceID: name, in: gridItemTransition)
                               )
                               // ---- End Destination Change ----
                           } label: {
                               GridItemView2(imageName: name)
                                   // Link this source view using its 'name'
                                   .matchedTransitionSource(id: name, in: gridItemTransition)
                           }
                           .buttonStyle(.plain)
                       }
                   }
                   .padding(20)
               }
           }
       }
}


#Preview {
 Galleryviewtests2()
}
