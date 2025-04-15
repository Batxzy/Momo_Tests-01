//
//  ModelTasks.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 15/04/25.
//

import SwiftUI

struct TaskItem: Identifiable {
    let id = UUID() // Conforms to Identifiable for use in ForEach
    var title: String
    var initialImageName: Image
    var finalImageName: Image
    var isCompleted: Bool = false
}
