//
//  TaskListView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 15/04/25.
//

import SwiftUI
import AnimateText

struct TaskListView: View {
    // MARK: - Propiedades
    
    @State private var tasks: [TaskItem]
       @State private var activeTaskIndex: Int? = nil
       @Environment(LevelManager.self) private var levelManager
       
       
       let staticDisplayImage: Image = Image("Dialogue_GreyMan")

       @State private var currentCompletionTexts: [String]
       @State private var textTransitionId = UUID()
       
       @State private var shouldUpdateCompletionTexts = false
       @State private var nextCompletionTexts: [String]?
    
    // MARK: - INIT
    init() {
            // Define the texts that appear when each task is completed.
            let catCompletionTexts = ["¡Bien hecho! Los gatos", "quitan el tiempo y distraen"]
            let romanceCompletionTexts = ["Perdías dinero en las flores ", "y tiempo en las visitas."]
        let friendsCompletionTexts = ["¡Perfecto!" ," Después tendrás tiempo ", "de convivir, ahora no."]
            
            _tasks = State(initialValue: [
                TaskItem(
                    title: "Dar en adopcion al gato",
                    initialImageName: Image("interaccion8(1)"), // Image for the ImageChangeView overlay
                    completionTexts: catCompletionTexts
                ),
                TaskItem(
                    title: "Dejar ir tu interés romántico",
                    initialImageName: Image("interaccion8(2)"),
                    completionTexts: romanceCompletionTexts
                ),
                TaskItem(
                    title: "Menos salidas con amigos",
                    initialImageName: Image("interaccion8(3)"),
                    completionTexts: friendsCompletionTexts
                )
            ])
            
            _currentCompletionTexts = State(initialValue: ["Cumple todas las tareas"])
        }
    
    // MARK: - Funciones
    private func handleTaskTap(at index: Int) {
        if !tasks[index].isCompleted && activeTaskIndex == nil {
            
            //** Controla cuanto dura la animacion al pasar a la tarea inicio **//
            withAnimation(.easeInOut(duration: 0.9)) {
                activeTaskIndex = index
            }
        }
    }
    
    private func completeTask(at index: Int) {
        guard tasks.indices.contains(index) else { return
        }
        
        tasks[index].isCompleted = true
        
        nextCompletionTexts = tasks[index].completionTexts // Set the texts for the completed task
        shouldUpdateCompletionTexts = true
        
        //** Controla cuanto dura la animacion al pasar a la tarea final **//
        withAnimation(.easeInOut(duration: 0.9)) {
            activeTaskIndex = nil
        }
        
        //** Controla el delay antes de ir a la siguiente pantalla **//
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if tasks.allSatisfy({ $0.isCompleted }) {
                performFinalAction()
            }
        }
    }
    private func performFinalAction() {
        levelManager.completeLevel()
    }
    
    // MARK: - View
    var body: some View {
        ZStack {
            // !! color temporal en lo que hay un fondo, sirve para que la transcion funcione y respete los bordes!!
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            //-- contenedor imagen y tareas-//
            VStack (spacing: 35){
                
                //-- contenedor de la lista de tareas --//
                VStack(spacing: 30) {
                ForEach(tasks.indices, id: \.self) { index in
                                TaskRowButton(
                                    task: tasks[index],
                                    isDisabled: activeTaskIndex != nil,
                                    onTap: {
                                        handleTaskTap(at: index)
                                    }
                                )
                            }
                        }
                    .padding()
                
                VStack(spacing: 19) {
                    HStack {
                        Spacer ()
                        
                        staticDisplayImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 236, height: 90.5)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .contentShape(Rectangle())
                    }
                    
                    HStack{
                        if !currentCompletionTexts.isEmpty {
                            DialogueTextView(
                                texts: currentCompletionTexts,
                                textFont: Font.Patrick18,
                                textAppearDelay: 0.05,
                                textLineSpacing: 2.0,
                                enableConstantShake: true,
                                constantShakeIntensity: 0,
                                constantShakeSpeed: 0,
                                onAnimationComplete: {
                                }
                            )
                            .padding(16)
                            .frame(width: 236,height: 90.5)
                            .fixedSize(horizontal: false, vertical: true)
                            .background(Color.black.opacity(0.75))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .id(textTransitionId)
                            .transition(.opacity.combined(with: .offset(y: 10)))
                        }
                        Spacer()
                    }
                }
                .frame(width: 300, height: 200)
                
            }
            .padding(20)
            .disabled(activeTaskIndex != nil)
                            
                            if let index = activeTaskIndex {
                                ImageChangeView(
                                    initialImage: tasks[index].initialImageName,
                                    onComplete: {
                                        completeTask(at: index)
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading)
                                ))
                                .ignoresSafeArea()
                                .zIndex(1)
                            }
                        }
                        .onChange(of: activeTaskIndex) { oldValue, newValue in
                           
                            if newValue == nil && shouldUpdateCompletionTexts {
                                if let nextTexts = self.nextCompletionTexts {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(.easeInOut(duration: 0.6)) {
                                            textTransitionId = UUID()
                                            currentCompletionTexts = nextTexts
                                        }
                                        shouldUpdateCompletionTexts = false
                                        self.nextCompletionTexts = nil
                                    }
                                } else {
                                    shouldUpdateCompletionTexts = false
                                }
                            }
                        }
                    }
                }
    // MARK: - Helper Views
struct TaskRowButton: View { // No changes needed from previous version
    let task: TaskItem
    let isDisabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(task.title)
                .font(.Patrick40) // Ensure this custom font is available
                .strikethrough(task.isCompleted, color: .gray)
                .foregroundColor(task.isCompleted ? .gray : .primary)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        .disabled(task.isCompleted || isDisabled)
        .opacity(isDisabled && !task.isCompleted ? 0.6 : 1.0)
    }
}
    


// MARK: - Preview Provider
#Preview {
    TaskListView()
        .environment(LevelManager())
}
