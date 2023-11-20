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
    func postData(object: TaskItem) async throws {
        var request = try await URLRequest(url: getTaskUrl())
        request.httpMethod = HttpMethod.POST.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(object)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw HttpError.BadResponse
        }
    }
    
    // UPDATE (PUT)
    func putData(object: TaskItem) async throws {
        var request = try await URLRequest(url: getTaskUrl())
        request.httpMethod = HttpMethod.PUT.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(object)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw HttpError.BadResponse
        }
    }
    
    // DELETE
    func deleteData(at id: String) async throws {
        var request = try await URLRequest(url: getTaskUrl())
        request.httpMethod = HttpMethod.DELETE.rawValue

        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw HttpError.BadResponse
        }
    }
}

