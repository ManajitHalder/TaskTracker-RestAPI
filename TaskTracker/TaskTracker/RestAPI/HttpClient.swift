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
    case PATCH
    case DELETE
}

enum HttpError: Error {
    case BadRequest // HTTP status code 400
    case UnauthorizedRequest // HTTP status code 401
    case RequestForbidden // HTTP status code 403
    case ResourceNotFound // HTTP status code 404
    case InternalServerError // HTTP status code 500
    case Unknown // HTTP status code unknown
}

func taskUrl() async throws -> URL {
    guard let url = URL(string: "https://tasktracker.apiblueprint.org/v1/tasks") else {
        throw HttpError.BadRequest
    }
    
    return url
}

class HttpClient {
    private init() {}
    static let shared = HttpClient()
    
    var taskURL: URL {
        get async throws {
            guard let url = URL(string: "https://private-96be530-tasktracker1.apiary-mock.com/v1/tasks") else {
                throw HttpError.BadRequest
            }
            
            return url
        }
    }
    
    func getTaskUrl() async throws -> URL {
        guard let url = URL(string: "https://private-96be530-tasktracker1.apiary-mock.com/v1/tasks") else {
            throw HttpError.BadRequest
        }
        
        return url
    }
    
    func handleHttpError(errorCode: Int?) async throws {
        switch errorCode {
        case 400:
            throw HttpError.BadRequest
        case 401:
            throw HttpError.UnauthorizedRequest
        case 403:
            throw HttpError.RequestForbidden
        case 404:
            throw HttpError.ResourceNotFound
        case 500:
            throw HttpError.InternalServerError
        default:
            throw HttpError.Unknown
        }
    }
    
    func handleJSONDecodingError(_ error: DecodingError) {
        switch error {
        case .dataCorrupted(let context):
            print("Data corrupted: \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            print("Key '\(key.stringValue)' not found in \(context.debugDescription)")
        case .typeMismatch(let type, let context):
            print("Type mismatch for type '\(type)' in \(context.debugDescription)")
        case .valueNotFound(let type, let context):
            print("Value not found for type '\(type)' in \(context.debugDescription)")
        @unknown default:
            print("An unknown decoding error occurred")
        }
    }
    
    // GET
    func fetchTaskData() async throws -> [TaskItem] {
        var request = try await URLRequest(url: taskURL)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        if responseCode != 200 {
            try await handleHttpError(errorCode: responseCode)
        }

        var taskData: [TaskItem] = []
        do {
            taskData = try JSONDecoder().decode([TaskItem].self, from: data)
        } catch let error as DecodingError {
            handleJSONDecodingError(error)
        } catch {
            print("An unexpected error occurred \(error)")
        }
        
        return taskData
    }
    
    // POST
    func postTaskData(object: TaskItem) async throws {
        var request = try await URLRequest(url: getTaskUrl())
        request.httpMethod = HttpMethod.POST.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = try? JSONEncoder().encode(object)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw HttpError.BadRequest
        }
    }
    
    // UPDATE (PUT)
    func putTaskData(object: TaskItem) async throws {
        var request = try await URLRequest(url: getTaskUrl())
        request.httpMethod = HttpMethod.PUT.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(object)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw HttpError.BadRequest
        }
    }
    
    // POST, PUT and PATCH TaskItem
    func sendTaskData(object: TaskItem, httpMethod: HttpMethod) async throws {
        var request = try await URLRequest(url: taskURL)
        request.httpMethod = httpMethod.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = try? JSONEncoder().encode(object)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        if responseCode != 200 {
            try await handleHttpError(errorCode: responseCode)
        }
    }
    
    // DELETE
    func deleteTaskData(at id: String) async throws {
        var request = try await URLRequest(url: taskURL)
        request.httpMethod = HttpMethod.DELETE.rawValue

        let (_, response) = try await URLSession.shared.data(for: request)
        
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        if responseCode != 200 {
            try await handleHttpError(errorCode: responseCode)
        }
    }
}

