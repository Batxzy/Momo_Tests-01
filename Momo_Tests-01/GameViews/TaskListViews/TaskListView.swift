//
//  TaskListView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 15/04/25.
//

import SwiftUI


import SwiftUI

struct TaskListView: View {
    // MARK: - Propiedades
    
    @State private var tasks: [TaskItem]
    
    @State private var activeTaskIndex: Int? = nil
    
    @Environment(LevelManager.self) private var levelManager
    
    @State private var currentDialogImage: Image
    
    @State private var imageTransitionId = UUID()
    
    @State private var shouldUpdateDialogImage = false
    
    @State private var nextDialogImage: Image?
    
    // MARK: - INIT
    init() {
        let defaultDialogImage = Image("Reason")
        
        // Initialize tasks with consistent structure
        _tasks = State(initialValue: [
            TaskItem(
                title: "Actividad 1",
                initialImageName: Image("rectangle33"),
                finalImageName: Image("rectangle35"),
                Dialogueimage: Image("Reason")
            ),
            TaskItem(
                title: "Actividad 2",
                initialImageName: Image("rectangle33"),
                finalImageName: Image("rectangle35"),
                Dialogueimage: Image("rectangle33")
            ),
            TaskItem(
                title: "Actividad 3",
                initialImageName: Image("rectangle33"),
                finalImageName: Image("rectangle35"),
                Dialogueimage: Image("rectangle35")
            ),
            TaskItem(
                title: "Actividad 4",
                initialImageName: Image("rectangle33"),
                finalImageName: Image("rectangle35"),
                Dialogueimage: Image("Reason")
            ),
            TaskItem(
                title: "Actividad 5",
                initialImageName: Image("rectangle33"),
                finalImageName: Image("rectangle35"),
                Dialogueimage: Image("rectangle35")
            )
        ])
        _currentDialogImage = State(initialValue: defaultDialogImage)
    }
    
    // MARK: - Funciones
    private func handleTaskTap(at index: Int) {
        if !tasks[index].isCompleted && activeTaskIndex == nil {
            withAnimation(.easeInOut(duration: 0.5)) {
                activeTaskIndex = index
            }
        }
    }
    
    private func completeTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        
        tasks[index].isCompleted = true
        
        // Store which dialog image to show next
        nextDialogImage = tasks[index].Dialogueimage
        shouldUpdateDialogImage = true
        
        // Only hide the ImageChangeView now - dialog image will update later
        withAnimation(.easeInOut(duration: 0.5)) {
            activeTaskIndex = nil
        }
        
        // Check if all tasks are completed after a delay
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
            // Main content
            VStack (spacing: 45){
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
                
                
                
                // Dialog image in separate container
                currentDialogImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 200)
                    .clipped()
                    .contentShape(Rectangle())
                    .id(imageTransitionId)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 1.05)),
                        removal: .opacity.combined(with: .scale(scale: 0.95))
                    ))
            }
            .disabled(activeTaskIndex != nil)
            
            // Overlay for active task
            if let index = activeTaskIndex {
                ImageChangeView(
                    initialImage: tasks[index].initialImageName,
                    finalImage: tasks[index].finalImageName,
                    onComplete: {
                        completeTask(at: index)
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .ignoresSafeArea()
                .zIndex(1) // Ensure it's on top
            }
            
        }
        .onChange(of: activeTaskIndex) {
            if activeTaskIndex == nil && shouldUpdateDialogImage, let nextImage = nextDialogImage {
        
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        imageTransitionId = UUID()
                        currentDialogImage = nextImage
                    }
                    shouldUpdateDialogImage = false
                    nextDialogImage = nil
                }
            }
        }
    }
}
    // MARK: - Helper Views
struct TaskRowButton: View {
    let task: TaskItem
    let isDisabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
                Text(task.title)
                    .font(.largeTitle)
                    .strikethrough(task.isCompleted, color: .gray)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                    .padding(5)
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
