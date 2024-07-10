//
//  TaskViewModel.swift
//  To-Do List App
//
//  Created by prathap on 09/07/24.
//

import UIKit

enum SortType: String {
    case name = "Sort by Name"
    case dueDate = "Sort by Due Date"
}

enum ChoosePriority: String {
    case all, low, medium, high
}

class TaskViewModel {
        
    private var allTasks = [Task]() {
        didSet {
            updateFilteredTasks()
        }
    }
    
    var completedTasks = [Task]() {
        didSet {
            reloadTableViewClosure?()
        }
    }
    
    var filteredTasks = [Task]() {
        didSet {
            reloadTableViewClosure?()
        }
    }
    
    var isSearching: Bool = false {
        didSet {
            updateFilteredTasks()
        }
    }
    
    var searchQuery: String? {
        didSet {
            updateFilteredTasks()
        }
    }
    
    var selectedPriority: ChoosePriority = .all {
        didSet {
            updateFilteredTasks()
        }
    }
    
    var selectedSortType: SortType = .name {
        didSet {
            updateFilteredTasks()
        }
    }
    
    // Closures
    var reloadTableViewClosure: (() -> Void)?
    var noResultsClosure: ((Bool) -> Void)?
    
    init() {
        loadAllTasksData()
    }
    
    func loadAllTasksData() {
        allTasks = UserDefaultsManager.shared.getTasks()
    }
    
    func addTask(_ task: Task) {
        UserDefaultsManager.shared.addTasks(task)
        loadAllTasksData()
    }
    
    func updateTask(_ task: Task) {
        UserDefaultsManager.shared.updateTask(task)
        loadAllTasksData()
    }
    
    func deleteTask(_ id: UUID) {
        UserDefaultsManager.shared.deleteTask(by: id)
        loadAllTasksData()
    }
    
    func completedTask() {
        loadAllTasksData()
        let filteredTask = allTasks.filter { $0.isCompleted }
        completedTasks = filteredTask
        noResultsClosure?(filteredTask.isEmpty)
    }
    
    private func updateFilteredTasks() {
        var tasks = allTasks
        
        // Filter by search query
        if isSearching, let query = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty {
            let lowercasedQuery = query.lowercased()
            tasks = tasks.filter { $0.name.lowercased().contains(lowercasedQuery) }
        }
        
        // Filter by priority
        switch selectedPriority {
        case .all:
            break
        case .low:
            tasks = tasks.filter { $0.priority == .low }
        case .medium:
            tasks = tasks.filter { $0.priority == .medium }
        case .high:
            tasks = tasks.filter { $0.priority == .high }
        }
        
        // Sort tasks
        switch selectedSortType {
        case .name:
            tasks = tasks.sorted(by: { $0.name < $1.name })
        case .dueDate:
            tasks = tasks.sorted(by: { $0.dueDate < $1.dueDate })
        }
        
        filteredTasks = tasks
        noResultsClosure?(tasks.isEmpty)
    }
    
    // TableView cell
    func attributedTaskName(index: Int) -> NSAttributedString {
        let task = filteredTasks[index]
        let attributeString = NSMutableAttributedString(string: task.name)
        if task.isCompleted {
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
        }
        return attributeString
    }
    
    func attributedCompletedTaskName(index: Int) -> NSAttributedString {
        let task = completedTasks[index]
        let attributeString = NSMutableAttributedString(string: task.name)
        if task.isCompleted {
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
        }
        return attributeString
    }
    
    func priorityTitleForCompletedTask(index: Int) -> String {
        return completedTasks[index].priority.title
    }
    
    func dueDateStringForCompletedTask(index: Int) -> Date {
        return completedTasks[index].dueDate
    }
    
    func priorityTitle(index: Int) -> String {
        return filteredTasks[index].priority.title
    }
    
    func dueDateString(index: Int) -> Date {
        return filteredTasks[index].dueDate
    }
    
    func completionImage(index: Int) -> UIImage? {
        return UIImage(systemName: filteredTasks[index].isCompleted ? "checkmark.circle.fill" : "circle")
    }
    
    func isOverdue(index: Int) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let taskDueDate = calendar.startOfDay(for: filteredTasks[index].dueDate)

        return taskDueDate < today
    }
}
