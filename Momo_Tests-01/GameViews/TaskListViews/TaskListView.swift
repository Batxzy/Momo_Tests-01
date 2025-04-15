//
//  TaskListView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 15/04/25.
//

import SwiftUI


struct TaskListView: View {
    // State for the tasks
    @State private var tasks: [TaskItem] = [
        TaskItem(title: "Actividad 1",
             initialImageName: Image(  "rectangle33"),
             finalImageName: Image( "rectangle35")),
        TaskItem(title: "Actividad 2",
             initialImageName: Image(  "rectangle33"),
             finalImageName: Image( "rectangle35")),
    ]

    @State private var activeTaskIndex: Int? = nil

    var body: some View {
        ZStack {
            // The main list of tasks
            VStack() {
                ForEach(tasks.indices, id: \.self) { index in
                    HStack {
                        Text(tasks[index].title)
                            .font(.largeTitle)
                            .strikethrough(tasks[index].isCompleted, color: .gray) // Apply strikethrough if completed
                            .foregroundColor(tasks[index].isCompleted ? .gray : .primary)
                    }
                    .padding(.vertical, 5)
                    .onTapGesture {
                        if !tasks[index].isCompleted && activeTaskIndex == nil {
                            activeTaskIndex = index
                        }
                    }
                    Divider()
                }
            }
            .padding()

            // Conditionally overlay the ImageChangeView
            if let index = activeTaskIndex {
                ImageChangeView(
                    initialImage: tasks[index].initialImageName,
                    finalImage: tasks[index].finalImageName,
                    onComplete: {
                        completeTask(at: index)
                    }
                )
                // Ensure it covers the whole screen if needed
                 .edgesIgnoringSafeArea(.all)
            }
        }
    }

    // Function called by ImageChangeView's completion callback
    private func completeTask(at index: Int) {
        // Ensure the index is valid
        guard tasks.indices.contains(index) else { return }

        // Mark the task as completed
        tasks[index].isCompleted = true

        // Hide the ImageChangeView
        activeTaskIndex = nil

        // Check if all tasks are completed
        if tasks.allSatisfy({ $0.isCompleted }) {
            // All tasks are done, call your final action
            performFinalAction()
        }
    }

    // Placeholder for your final action
    private func performFinalAction() {
        print("All tasks completed! Performing final action.")
    }
}

#Preview {
    TaskListView()
}
