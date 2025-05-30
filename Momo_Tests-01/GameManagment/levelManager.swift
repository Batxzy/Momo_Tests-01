//
//  levelmanager.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 10/04/25.
//

import Foundation
import SwiftUI

@Observable class LevelManager {
    
    //MARK: -variables y propiedades calculadas
    var chapters: [Chapter]
    var Parts: [Part]
    var currentChapterIndex: Int
    var currentLevelIndex: Int
    var transitionType: LevelTransition?
    var showChapterCompletionFade: Bool = false
    
    // Para imprimr en la consola
    var lastActionLog: String = ""
    var updateCounter: Int = 0
    
    var currentChapter: Chapter {
        chapters[currentChapterIndex]
    }
    
    var currentLevel: Level {
        currentChapter.levels[currentLevelIndex]
    }
    
    private var hasNextLevelInCurrentChapter: Bool {
        currentLevelIndex + 1 < currentChapter.levels.count
    }
    
    private var hasNextChapter: Bool {
        currentChapterIndex + 1 < chapters.count
    }
    
    var onChapterCompleteNavigation: (() -> Void)?
    
    //MARK: - funciones
    

    func completeLevel() {

        //para cuidar si el indice no esta bien que la funcion no truene
        guard chapters.indices.contains(currentChapterIndex),
              chapters[currentChapterIndex].levels.indices.contains(currentLevelIndex) else {
            print("Error: Invalid state in completeLevel")
            return
        }
        
        //toggle a que ya esta completado en el struct
        chapters[currentChapterIndex].levels[currentLevelIndex].isCompleted = true
        print("Completed Level: Chapter \(currentChapterIndex + 1), Level \(currentLevelIndex + 1)")

        
        //si tiene otro nivel en el capitulo --- esta es la parte que triggerea el avance al siguiente nivel
        if hasNextLevelInCurrentChapter {
            currentLevelIndex += 1
            updateCounter += 1
            lastActionLog = "Advanced to Level \(currentLevelIndex + 1) in Chapter \(currentChapterIndex + 1)"
            print(lastActionLog)
        } else {
            // --- Chapter Logic --- //
            lastActionLog = "Completed Chapter \(currentChapterIndex + 1)"
            print(lastActionLog)
            
          //si hay otro capitulo lo desbloquea desde aca
            if hasNextChapter {
                chapters[currentChapterIndex + 1].isUnlocked = true
                print("Unlocked Chapter \(currentChapterIndex + 2)")
            } else {
                handleGameCompletion()
            }

            updateCounter += 1
            
            showChapterCompletionFade = true
        }
    }
        private func handleGameCompletion() {
            print("All chapters and levels completed!")
            lastActionLog = "Game completed!"
        }
        
        func startGame(chapterIndex: Int) {
            currentChapterIndex = chapterIndex
            currentLevelIndex = 0
            showChapterCompletionFade = false
        }
//MARK: -Init con los datos
        init() {
            // --- Datos ---
            let chapter1Levels = [
                
                Level(id: UUID(),
                      name: "1",
                      content: AnyView(ChapterIntroView()),
                      transition: .cameraPan,
                      isCompleted: false,
                     ),
                
                
                Level(id: UUID(),
                      name: "1_1",
                      content: AnyView(ImageScrollView(images: Scroll_1_1)),
                      transition: .cameraPan,
                      isCompleted: false,
                     ),
                
                Level(
                    id: UUID(),
                    name: "Dust Remover",
                    content: AnyView(DustRemoverView2(
                        backgroundImage: Image("Scratch_game_1_1 (1)"),
                        foregroundImage: Image("Scratch_game_1_1 (2)"),
                        backgroundWidth: 334,
                        backgroundHeight: 720,
                        foregroundWidth: 334,
                        foregroundHeight: 720,
                        completionThreshold: 90.0)
                    ),
                    transition: .cameraPan,
                    isCompleted: false
                ),
                
                Level(
                    id: UUID(),
                    name: "ListenGame_1",
                    content: AnyView(TapProgressView(FirstIllustration: Image("ListenGame_1(1)"), SecondIllustration: Image("ListenGame_1(2)"))),
                    transition: .cameraPan,
                    isCompleted: false
                ),
                
                Level(
                    id: UUID(),
                    name: "Eating",
                    content: AnyView(CirclesView(ilustration:Image("Eating_1(1)"))),
                    transition: .cameraPan,
                    isCompleted: false
                ),
                
                Level(
                    id: UUID(),
                    name: "Cat_Drag",
                    content: AnyView(DragProgressView(
                        swipeSensitivity: 8.0, Ilustration: Image("Cat_Game_1_(1)"), secondIlustration: Image("Cat_Game_1_(2)"))
                    ),
                    transition: .cameraPan,
                    isCompleted: false
                ),
                
                Level(
                    id: UUID(),
                    name: "Old_Man_dreams",
                    content: AnyView(DustRemoverView2(
                        backgroundImage: Image("Scratch_game_1_2 (1)"),
                        foregroundImage: Image("Scratch_game_1_2 (2)"),
                        backgroundWidth: 334,
                        backgroundHeight: 720,
                        foregroundWidth: 334,
                        foregroundHeight: 254,
                        completionThreshold: 90.0)
                    ),
                    transition: .cameraPan,
                    isCompleted: false
                ),
                
                Level(id: UUID(),
                      name: "1_2",
                      content: AnyView(ImageScrollView(images: Scroll_1_2)),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
             
                Level(id: UUID(),
                      name: "blank",
                      content: AnyView(blankview()),
                      transition: .cameraPan,
                      isCompleted: false)
                
            ]
            
            let chapter2Levels = [
                
                Level(id: UUID(),
                      name: "2",
                      content: AnyView(ChapterIntroView()),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                
                Level(id: UUID(),
                      name: "2_1",
                      content: AnyView(ImageScrollView(images: Scroll_2_1)),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                
                
                Level(id: UUID(),
                      name: "Dialogue_2_1",
                      content: AnyView( DialogueView(
                        dialogueTexts: [ "¿Te preocupa"," el futuro?"
                        ],
                        illustrationImage: Image("Dialogue_2 (1)"),
                        textFont: .Patrick48,
                        textAppearDelay: 3,
                        textLineSpacing: 2,
                        enableConstantShake: true,
                        constantShakeIntensity: 0.8,
                        constantShakeSpeed: 2.2)
                      ),
                      transition: .cameraPan,
                      isCompleted: false),
                
                Level(id: UUID(),
                      name: "Dialogue_2_2",
                      content: AnyView(DialogueView(
                        dialogueTexts: [ "¿Cuánto habrías", "logrado si hubieras", "comenzado antes?"
                        ],
                        illustrationImage: Image("Dialogue_2 (2)"),
                        textFont: .Patrick32,
                        textAppearDelay: 3,
                        textLineSpacing: 2,
                        enableConstantShake: true,
                        constantShakeIntensity: 0.8,
                        constantShakeSpeed: 2.2)
                      ),
                      transition: .cameraPan,
                      isCompleted: false),
                
                Level(id: UUID(),
                      name: "Dialogue_2_3",
                      content: AnyView(DialogueView(
                        dialogueTexts: [ "¿Realmente puedes ", "permitirte el lujo de", "detenerte ahora?"
                        ],
                        illustrationImage: Image("Dialogue_2 (3)"),
                        textFont: .Patrick32,
                        textAppearDelay: 3,
                        textLineSpacing: 2,
                        enableConstantShake: true,
                        constantShakeIntensity: 0.8,
                        constantShakeSpeed: 2.2)
                      ),
                      
                      transition: .cameraPan,
                      isCompleted: false),
                Level(id: UUID(),
                      name: "Dialogue_2_4",
                      content: AnyView(DialogueView(
                        dialogueTexts: [ "Recuerda que ya","no hay vuelta atrás"
                        ],
                        illustrationImage: Image("Dialogue_2 (4)"),
                        textFont: .Patrick32,
                        textAppearDelay: 3,
                        textLineSpacing: 10,
                        enableConstantShake: true,
                        constantShakeIntensity: 0.8,
                        constantShakeSpeed: 2.2)
                      ),
                      transition: .cameraPan,
                      isCompleted: false),
                        
                Level(id: UUID(),
                      name: "2_2",
                      content: AnyView(ImageScrollView(images:Scroll_2_2)),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                
                Level(id: UUID(),
                      name: "Tap_2-1",
                      content: AnyView(ImageTap(iulstration:Image ("Interaccion 7 mensaje 1"))),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                Level(id: UUID(),
                      name: "Tap_2-2",
                      content: AnyView(ImageTap(iulstration:Image ("Interaccion 7 mensaje 2"))),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                Level(id: UUID(),
                      name: "blank",
                      content: AnyView(blankview()),
                      transition: .cameraPan,
                      isCompleted: false)
                
                
            ]
            
            let chapter3Levels = [
                
                Level(id: UUID(),
                      name: "3",
                      content: AnyView(ChapterIntroView()),
                      transition: .cameraPan,
                      isCompleted: false,
                     ),
                
                Level(id: UUID(),
                      name: "TaskLsit",
                      content: AnyView(TaskListView()),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                Level(id: UUID(),
                      name: "2_3",
                      content: AnyView(ImageScrollView(images:Scroll_2_3)),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                Level(id: UUID(),
                      name: "Tap_2-3",
                      content: AnyView(ImageTapChange(
                        initialIllustration: Image("mapa1"),
                        nextIllustration: Image("mapa2"),
                        delay: 2.0)),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                /*
                Level(id: UUID(),
                      name: "2_4",
                      content: AnyView(ImageScrollView(images:Scroll_2_4)),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                 */
                Level(id: UUID(),
                      name: "blank",
                      content: AnyView(blankview()),
                      transition: .cameraPan,
                      isCompleted: false)
            ]
            
            let chapter4Levels = [
                Level(id: UUID(),
                      name: "4",
                      content: AnyView(ChapterIntroView()),
                      transition: .cameraPan,
                      isCompleted: false,
                     ),
                
                Level(id: UUID(),
                      name: "4_1",
                      content: AnyView(ImageScrollView(images: Scroll_4_1)),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                Level(
                    id: UUID(),
                    name: "Tap Game",
                    content: AnyView(TapProgressView(FirstIllustration: Image("rectangle33"), SecondIllustration: Image("rectangle35"))),
                    transition: .cameraPan,
                    isCompleted: false
                ),
                Level(id: UUID(),
                      name: "4_2",
                      content: AnyView(ImageScrollView(images: Scroll_4_2)),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                Level(id: UUID(),
                      name: "ImagePan",
                      content: AnyView(WideImageView()),
                      transition: .cameraPan,
                      isCompleted: false,
                     ),
                Level(id: UUID(),
                      name: "4_3",
                      content: AnyView(ImageScrollView(images: Scroll_4_3)),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                Level(id: UUID(),
                      name: "Tap_4-1",
                      content: AnyView(ImageTap(iulstration:Image ("rectangle35"))),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                Level(id: UUID(),
                      name: "4_4",
                      content: AnyView(ImageScrollView(images: Scroll_4_4)),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                Level(id: UUID(),
                      name: "blank",
                      content: AnyView(blankview()),
                      transition: .cameraPan,
                      isCompleted: false)
            ]
            
            let chapter5Levels = [
                Level(id: UUID(),
                      name: "5",
                      content: AnyView(ChapterIntroView()),
                      transition: .cameraPan,
                      isCompleted: false,
                     ),
                Level(id: UUID(),
                      name: "5_1",
                      content: AnyView(ImageScrollView(images: Scroll_5_1)),
                      transition: .cameraPan,
                      isCompleted: false
                     )
            ]
            
            let Chapter1 = Chapter(id: UUID(), title: "Rutina", levels: chapter1Levels, isUnlocked: true)
            let Chapter2 = Chapter(id: UUID(), title: "Hombres Grises", levels: chapter2Levels, isUnlocked: false)
            let Chapter3 = Chapter(id: UUID(), title: "Eficiencia", levels: chapter3Levels, isUnlocked: false)
            let Chapter4 = Chapter(id: UUID(), title: "Boveda del tiempo", levels: chapter4Levels, isUnlocked: false)
            let Chapter5 = Chapter(id: UUID(), title: "Amigos", levels: chapter5Levels, isUnlocked: false)
            
            self.chapters = [
               Chapter1,Chapter2,Chapter3,Chapter4,Chapter5
            ]
           
            
            let Part1 = Part(id: UUID(), title: "Parte 1", chapters: [Chapter1])
            let Part2 = Part(id: UUID(), title: "Parte 2", chapters: [Chapter2,Chapter3])
            let Part3 = Part(id: UUID(), title: "Parte 3", chapters: [Chapter4, Chapter5])
            
            self.Parts = [Part1,Part2,Part3]
            
            self.currentChapterIndex = 0 // Default start
            self.currentLevelIndex = 0   // Default start
            
            // asegurarse de que el primer capitulo si este desbloqueado
            if !chapters.isEmpty && !chapters[0].isUnlocked {
                self.chapters[0].isUnlocked = true
            }
            print("LevelManager initialized with \(chapters.count) chapters.")
        }
    }
