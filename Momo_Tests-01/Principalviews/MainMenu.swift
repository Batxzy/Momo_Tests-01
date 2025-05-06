//
//  MainMenu.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//

import SwiftUI

// MARK: - Menu principal View
struct MainMenu: View {
    @Environment(LevelManager.self) private var levelManager
    @Binding var path: NavigationPath

// MARK: - body
    var body: some View {
        VStack(spacing: 30) {
            
            // Imagen principal del menú
            Image("MOMO-main")
                .resizable()
                .scaledToFill()
                .frame(width: 288, height: 420)
                .clipped()
                .fadingEdgeGradient(topHeight: 0, bottomHeight: 20, solidStop: 1)

            //-- contenedor  de botones --//
            VStack(spacing: 8) {
                Button {
                    levelManager.startGame(chapterIndex: 0)
                    path.append(NavigationTarget.game)
                } label: {
                    Text("Nueva partida")
                        .font(.Patrick32)
                        .foregroundColor(.black)
                }
                .padding(12)

                Button {
                    path.append(NavigationTarget.chapterMenu)
                } label: {
                    Text("Capitulos")
                        .font(.Patrick32)
                        .foregroundColor(.black)
                }
                .padding(12)

                Button {
                    path.append(NavigationTarget.gallery)
                } label: {
                    Text("Galeria")
                        .font(.Patrick32)
                        .foregroundColor(.black)
                }
                .padding(12)

                Text("Configuracion")
                    .font(.Patrick32)
                    .padding(12)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Previsualización para Xcode
#Preview {
    struct PreviewWrapper: View {
        @State var previewPath = NavigationPath()
        @State var previewLevelManager = LevelManager()

        var body: some View {
            NavigationStack(path: $previewPath) {
                MainMenu(path: $previewPath)
                    .navigationDestination(for: NavigationTarget.self) { target in
                        switch target {
                        case .game:
                            Text("Preview: Navigated to Game View")
                                .navigationTitle("Game Preview")
                                .navigationBarBackButtonHidden(true)
                        case .chapterMenu:
                            Text("Preview: Navigated to Chapter Menu")
                                .navigationTitle("Chapters Preview")
                        case .gallery:
                            Galleryview(path: $previewPath)
                                .navigationTitle("Gallery Preview")
                        case .imageDetail(let names, let selected, _):
                            Text("Preview: Image Detail for \(selected) (\(names.count) total)")
                                .navigationTitle("Image Detail Preview")
                        }
                    }
            }
            .environment(previewLevelManager)
        }
    }
    return PreviewWrapper()
}
