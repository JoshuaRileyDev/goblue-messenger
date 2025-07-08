//
//  Actions.swift
//  goblue
//
//  Created by Joshua Riley on 27/02/2025.
//

import Foundation
import SwiftUI
import AppIntents

struct GetMessages: AppIntent {
    static var title: LocalizedStringResource = "Get Messages"
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        @AppStorage("apiKey") var apiKey: String = ""

        // Ensure we have a valid API key
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .result(value: "[]")
        }

        // Create URL with proper encoding
        guard let encodedKey = apiKey.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://api.goblue.app/v1/poll/\(encodedKey)") else {
            return .result(value: "[]") 
        }

        // Configure request with timeout and caching policy
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        do {
            let config = URLSessionConfiguration.default
            config.waitsForConnectivity = true
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 300
            let session = URLSession(configuration: config)
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .result(value: "[]")
            }
            
            // Handle various HTTP status codes
            switch httpResponse.statusCode {
            case 200:
                // Attempt to parse JSON response
                guard let jsonString = String(data: data, encoding: .utf8) else {
                    return .result(value: "[]")
                }
                return .result(value: jsonString)
                
            case 401, 403:
                // Invalid or expired API key
                return .result(value: "[]")
                
            case 429:
                // Rate limited
                try await Task.sleep(nanoseconds: 2_000_000_000) // Wait 2 seconds
                return try await perform() // Retry once
                
            default:
                return .result(value: "[]")
            }
            
        } catch URLError.timedOut {
            // Handle timeout specifically
            return .result(value: "[]")
            
        } catch URLError.notConnectedToInternet {
            // Handle no internet specifically  
            return .result(value: "[]")
            
        } catch {
            // Handle all other errors
            return .result(value: "[]")
        }
    }
}

struct UpdateContact: AppIntent {
    static var title: LocalizedStringResource = "Update Contact"

    @Parameter(title: "Phone Number")
    var phoneNumber: String
    
    
    func perform() async throws -> some IntentResult {
        @AppStorage("apiKey") var apiKey: String = ""

        guard !apiKey.isEmpty else {
            return .result()
        }

        let url = URL(string: "https://api.goblue.app/v1/reply/\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body = ["phoneNumber": phoneNumber]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            return .result()
        }
        
        // Convert data to JSON string7
        guard let jsonString = String(data: data, encoding: .utf8) else {
            return .result()
        }
        
        return .result()
    }
}


struct GetLeadPhoto: AppIntent {
    static var title: LocalizedStringResource = "Get Lead Photo"

    @AppStorage("leadPhoto") var leadPhoto: String = ""

    func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
        let uiImage = getImage(leadPhoto, "leadPhoto")
        let intentFile = IntentFile(data: uiImage.pngData()!, filename: "leadPhoto.png", type: .png)
        return .result(value: intentFile)
    }
}