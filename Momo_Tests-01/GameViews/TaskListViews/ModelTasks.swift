//
//  ModelTasks.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 15/04/25.
//

import SwiftUI

struct TaskItem: Identifiable {
    let id = UUID()
        var title: String
        var initialImageName: Image 
        var completionTexts: [String]
        var isCompleted: Bool = false
}
