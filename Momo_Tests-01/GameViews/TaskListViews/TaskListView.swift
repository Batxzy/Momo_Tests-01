//
//  TaskListView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 15/04/25.
//

import SwiftUI


struct TaskListView: View {
    
    @State private var tasks: [TaskItem]

    @State private var activeTaskIndex: Int? = nil
    
    init(){
        let initialTaskData: [TaskItem] = [
            
            TaskItem(
                title: "Actividad 1",
                initialImageName: Image("rectangle33"),
                finalImageName: Image("rectangle35")
                ),
            
            TaskItem(
                title: "Actividad 1",
                initialImageName: Image("rectangle33"),
                finalImageName: Image("rectangle35")
                )
        ]
        _tasks = State(initialValue: initialTaskData)
    }
    
    var body: some View {
        ZStack {
            VStack() {
                ForEach(tasks.indices, id: \.self) { index in
                    HStack {
                        Text(tasks[index].title)
                            .font(.largeTitle)
                            .strikethrough(tasks[index].isCompleted, color: .gray)
                            .foregroundColor(tasks[index].isCompleted ? .gray : .primary)
                    }
                    .padding(10)
                    .onTapGesture {
                        if !tasks[index].isCompleted && activeTaskIndex == nil {
                            
                            withAnimation(.easeInOut(duration: 0.5)) {
                                activeTaskIndex = index
                            }
                        }
                    }
                    Divider()
                }
            }
            .padding()
            .disabled(activeTaskIndex != nil)

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
                .edgesIgnoringSafeArea(.all)
                .zIndex(1)
            }
        }
    }

    private func completeTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }

        tasks[index].isCompleted = true

        withAnimation(.easeInOut(duration: 0.5)) {
            activeTaskIndex = nil
        }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { // Adjust delay as needed
             if tasks.allSatisfy({ $0.isCompleted }) {
                 performFinalAction()
             }
        }
    }

    private func performFinalAction() {
        print("All tasks completed! Performing final action.")
    }
}


#Preview {
    TaskListView()
}
