//
//  HttpClient.swift
//
//  Created by Manajit Halder on 13/11/23 using Swift 5.0 on MacOS 13.4
//

import Foundation

enum HttpMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

enum HttpError: Error {
    case BadURL
    case BadResponse
    case DecodingError
    case InvalidURL
}

func taskUrl() async throws -> URL {
    guard let url = URL(string: "ss") else {
        throw HttpError.BadURL
    }
    
    return url
}

class HttpClient {
    private init() {}
    static let shared = HttpClient()
    
    func getTaskUrl() async throws -> URL {
        guard let url = URL(string: "https://private-96be530-tasktracker1.apiary-mock.com/v1/tasks") else {
            throw HttpError.BadURL
        }
        
//        var taskUrl = URLRequest(url: url)
//        taskUrl.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        taskUrl.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return url
    }
    
    // GET
    func getData() async throws -> [TaskItem] {
        let (data, response) = try await URLSession.shared.data(from: getTaskUrl())
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw HttpError.BadResponse
        }
        
        guard let taskData = try? JSONDecoder().decode([TaskItem].self, from: data) else {
            throw HttpError.DecodingError
        }
        
        return taskData
    }
    
    // POST
    func postData() {
        
    }
    
    // UPDATE (PUT)
    func putData() {
        
    }
    
    // DELETE
    func deleteData() {
        
    }
}

