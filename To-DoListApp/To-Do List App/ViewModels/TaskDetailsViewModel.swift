//
//  TaskDetailsViewModel.swift
//  To-Do List App
//
//  Created by prathap on 09/07/24.
//

import UIKit

enum TaskPriority: String, Codable {
    
    case high, medium, low
    
    var title: String {
        switch self {
        case .high:
            return "High"
        case .medium:
            return "Medium"
        case .low:
            return "Low"
        }
    }
}

class TaskDetailsViewModel {
    
    var selectedTask: Task?
    var taskViewModel = TaskViewModel()
    
    init(task: Task) {
        selectedTask = task
    }
    
    func updateTask(_ task: Task) {
        taskViewModel.updateTask(task)
    }
    
    func loadImageFromDocumentsDirectory(filename: String) -> UIImage? {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = paths.first else {
            return nil
        }
        
        let fileURL = documentDirectory.appendingPathComponent(filename)
        
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func loadPDFFromDocumentsDirectory(filename: String) -> Data? {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = paths.first else {
            return nil
        }
        
        let fileURL = documentDirectory.appendingPathComponent(filename)
        
        return try? Data(contentsOf: fileURL)
    }
}
