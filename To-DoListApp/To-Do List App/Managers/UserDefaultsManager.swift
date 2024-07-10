//
//  UserDefaultsManager.swift
//  Zoho Task
//
//  Created by prathap on 06/07/24.
//

import Foundation

import UIKit

struct Task: Codable {
    var id: UUID
    var name: String
    var description: String
    var isCompleted: Bool
    var priority: TaskPriority
    var dueDate: Date
    var attachment: [String]
}

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    private let tasksKey = "tasksKey"
    private init() {}
    
    private func saveTasks(_ tasks: [Task]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(tasks)
            UserDefaults.standard.set(data, forKey: tasksKey)
        } catch {
            print("Error encoding tasks: \(error)")
        }
    }
    
    func getTasks() -> [Task] {
        guard let data = UserDefaults.standard.data(forKey: tasksKey) else { return [] }
        do {
            let decoder = JSONDecoder()
            let tasks = try decoder.decode([Task].self, from: data)
            return tasks
        } catch {
            print("Error decoding tasks: \(error)")
            return []
        }
    }
    
    func deleteTask(by id: UUID) {
        var tasks = getTasks()
        tasks.removeAll { $0.id == id }
        saveTasks(tasks)
    }
    
    func updateTask(_ updatedTask: Task) {
        var tasks = getTasks()
        if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
            tasks[index] = updatedTask
            saveTasks(tasks)
        }
    }
    
    func addTasks(_ newTasks: Task) {
        var tasks = getTasks()
        tasks.append(newTasks)
        saveTasks(tasks)
    }
}
