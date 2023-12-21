//
//  TaskOperation.swift
//  
//  Created by Manajit Halder on 10/10/23 using Swift 5.0 on MacOS 13.4
//  

import Foundation
import Combine

final class TaskManager {
    func fetchAllTasks() async -> [TaskItem] {
        [
            TaskItem(title: "Task 1", description: "Start your first project Task Trakcer to track daily tasks", category: "Personal", priority: "High", status: "Not Started", taskDate: TaskDate(startDate: "", dueDate: DateUtils.dateToString(Date()), finishDate: "")),
            TaskItem(title: "Task 5", description: "", category: "Work", priority: "High", status: "Not Started", taskDate: TaskDate(startDate: "", dueDate: DateUtils.dateToString(Date()), finishDate: "")),
            TaskItem(title: "Task 7", description: "", category: "Shopping", priority: "High", status: "Not Started", taskDate: TaskDate(startDate: "", dueDate: DateUtils.dateToString(Date()), finishDate: "")),
            TaskItem(title: "Task 9", description: "", category: "Wishlist", priority: "High", status: "Not Started", taskDate: TaskDate(startDate: "", dueDate: DateUtils.dateToString(Date()), finishDate: "")),
            TaskItem(title: "Task 12", description: "", category: "Travel", priority: "High", status: "Not Started", taskDate: TaskDate(startDate: "", dueDate: DateUtils.dateToString(Date()), finishDate: "")),
            TaskItem(title: "Is not displaying complete description. I want to display complete description. Is not displaying complete description. I want to display complete description.", description: "Is not displaying complete description. I want to display complete description. Is not displaying complete description. I want to display complete description. Is not displaying complete description. I want to display complete description. Is not displaying complete description. I want to display complete description.", category: "Hobby", priority: "High", status: "Completed", taskDate: TaskDate(startDate: "", dueDate: DateUtils.dateToString(Date()), finishDate: "")),
            TaskItem(title: "Cook Khichdi", description: "Prepare Khichdi for dinner", category: "Other", priority: "High", status: "Not Started", taskDate: TaskDate(startDate: "", dueDate: DateUtils.dateToString(Date()), finishDate: "")),
            TaskItem(title: "I am loving this app.", description: "This app has boosted my confidence of app development using SwiftUI, Vapor, handing greate amout data, apiary, REST API, PostgreSQL.", category: "Work", priority: "High", status: "Not Started", taskDate: TaskDate(startDate: "", dueDate: DateUtils.dateToString(Date())), updates: [Update(text: "Started"), Update(text: "Preapared detailed plan"), Update(text: "Going good"), Update(text: "Learned so many things"), Update(text: "Finishing next week")]),
            TaskItem(title: "I am loving this app.", description: "This app has boosted my confidence of app development using SwiftUI, Vapor, handling great amount data, apiary, REST API, PostgreSQL.", category: "Work", priority: "High", status: "Completed", taskDate: TaskDate(startDate: "", dueDate: DateUtils.dateToString(Date()), finishDate: ""), updates: [Update(text: "Started"), Update(text: "Learning so many things on iOS and Swift. Going to implement backend next week."), Update(text: "Going good"), Update(text: "Learned so many things"), Update(text: "Finishing soon")])
        ]
    }
}

final class TaskMainViewModel: ObservableObject {
    
    @Published var allTasks: [TaskItem] = []
    @Published private(set) var filteredTasks: [TaskItem] = []
    @Published var completedTasks: [TaskItem] = [] // To maintain a list of completed tasks.
    @Published var searchText: String = ""
    @Published var useSegmentedPickerStyle: Bool = false
    
    let taskManager = TaskManager()
    private var cancellables = Set<AnyCancellable>()
    
    func loadTasks() async throws {
//        allTasks = taskManager.fetchAllTasks()
        Task {
            do {
                let tasks = try await HttpClient.shared.fetchTaskData()
                
                // Switch to main thread for UI updates
                DispatchQueue.main.async {
                    self.allTasks = tasks
                }
            } catch {
                print("Error in fetching task data")
            }
        }
    }
    
    
    
    //MARK: - SEARCH FUNCTIONALITIES
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    init() {
        Task {
            do {
                try await loadTasks()
            } catch HttpError.BadRequest {
                print("Bad request due to client error, may be bad URL")
            } catch HttpError.UnauthorizedRequest {
                print("Invalid authentication credentials")
            } catch HttpError.RequestForbidden {
                print("The server understood the request but refuses to authorize it")
            } catch HttpError.ResourceNotFound {
                print("The requested resource could not be found on the server")
            } catch HttpError.InternalServerError {
                print("An unexpected condition was encountered on the server")
            } catch {
                print("Error loading tasks: \(error)")
            }
        }
        
        addSubscribers()
    }
    
    private func addSubscribers() {
        $searchText
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.filterTasks(searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func filterTasks(searchText: String) {
//        Task {
            guard !searchText.isEmpty else {
                return
            }
            
            let search = searchText.lowercased()
            filteredTasks = allTasks.filter({ task in
                let titleContainsSearchText = task.title.lowercased().contains(search)
                let categoryContainsSearchText = task.category.lowercased().contains(search)
                let priorityContainsSearchText = task.priority.lowercased().contains(search)
                let statusContainsSearchText = task.status.lowercased().contains(search)
                
                return titleContainsSearchText || categoryContainsSearchText || priorityContainsSearchText || statusContainsSearchText
            })
//        }
    }
    
    //MARK: - TASK OPERATIONS
    
//    func addTask(_ task: TaskItem) {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//
//            self.allTasks.insert(task, at: 0)
//        }
//    }
    
    func addTask(_ task: TaskItem) {
        Task {
            do {
               try await HttpClient.shared.sendTaskData(object: task, httpMethod: HttpMethod.POST)
            } catch {
                print("Error in adding new task with error code \(error)")
            }
            
            do {
                try await loadTasks()
            } catch {
                print("Error in fetching tasks \(error)")
            }
        }
    }
    
    func updateTask(_ task: TaskItem) {
        Task {
            do {
                try await HttpClient.shared.sendTaskData(object: task, httpMethod: HttpMethod.PUT)
            } catch {
                print("Error in adding new task with error code \(error)")
            }
            
            do {
                try await loadTasks()
            } catch {
                print("Error in fetching tasks \(error)")
            }
        }
    }
    
    
//    func updateTask(_ task: TaskItem) {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//
//            if let taskIndex = allTasks.firstIndex(where: { $0.id == task.id }) {
//                allTasks[taskIndex].title = task.title
//                allTasks[taskIndex].description = task.description
//                allTasks[taskIndex].category = task.category
//                allTasks[taskIndex].priority = task.priority
//                allTasks[taskIndex].status = task.status
//                allTasks[taskIndex].taskDate.dueDate = task.taskDate.dueDate
//                allTasks[taskIndex].updates = task.updates
//            }
//        }
//    }
//
//    func deleteTask(_ task: TaskItem) {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else {
//                return
//            }
//            if let taskIndex = allTasks.firstIndex(where: { $0.id == task.id }) {
//                self.allTasks.remove(at: taskIndex)
//            }
//        }
//    }
  
    func deleteTask(with id: String) {
        Task {
            do {
                try await HttpClient.shared.deleteTaskData(with: id)
            } catch {
                print("Error in deleting task with error code \(error)")
            }
        }
    }
    
    // Add task to the completedTask array
    func addCompletedTask(_ completedTask: TaskItem) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.completedTasks.insert(completedTask, at: 0)
        }
    }
    
    //MARK: - CONTEXT MENU OPERATIONS
    
    // Start task
    func startTask(_ task: TaskItem, _ status: String, _ startDate: Date) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let taskIndex = allTasks.firstIndex(where:  { $0.id == task.id }) {
                allTasks[taskIndex].status = status
                allTasks[taskIndex].taskDate.startDate = DateUtils.dateToString(startDate)
            }
        }
    }
    
    // Complete task
    func completeTask(_ task: TaskItem, _ status: String, _ finishDate: Date) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let taskIndex = allTasks.firstIndex(where: { $0.id == task.id }) {
                allTasks[taskIndex].status = status
                allTasks[taskIndex].taskDate.finishDate = DateUtils.dateToString(finishDate)
                self.addCompletedTask(allTasks[taskIndex]) // Add the task to the completed task list
                self.deleteTask(with: allTasks[taskIndex].id) // Delete the task from the allTasks list
            }
        }
    }
    
    //MARK: - TASK FILTERING
    
}
