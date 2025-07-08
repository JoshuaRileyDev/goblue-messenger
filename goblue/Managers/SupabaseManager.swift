//
//  SupabaseManager.swift
//  goblue
//
//  Created by Joshua Riley on 11/02/2025.
//

import Foundation
import Supabase
import SwiftUI

struct SBForm: Codable {
    let id: UUID
    var name: String
    var message_template: String
    var enableCapturing: Bool
    var autoFollowUp: Bool
    var postLater: Bool
    var postLaterType: String
    var postLaterValue: Int
    var includeAttachment: Bool
    var attachmentType: String
    var attachmentValue: String
    let user_id: UUID
    
    init(id: UUID, name: String, message_template: String = "", enableCapturing: Bool = false, autoFollowUp: Bool = true, postLater: Bool = false, postLaterType: String = "minutes", postLaterValue: Int = 0, includeAttachment: Bool = false, attachmentType: String = "gif", attachmentValue: String = "", user_id: UUID) {
        self.id = id
        self.name = name
        self.message_template = message_template
        self.autoFollowUp = autoFollowUp
        self.enableCapturing = enableCapturing
        self.postLater = postLater
        self.postLaterType = postLaterType
        self.postLaterValue = postLaterValue
        self.includeAttachment = includeAttachment
        self.attachmentType = attachmentType
        self.attachmentValue = attachmentValue
        self.user_id = user_id
    }
}

struct SBFormField: Codable {
    let id: UUID
    let name: String
    let form_id: UUID
}

struct SBAPIKey: Codable {
    let id: UUID
    let key_value: String
    let user_id: UUID
    let lastUsed: Int
}

struct SBContact: Codable {
    let id: UUID
    var first_name: String
    var last_name: String
    var phoneNumber: String
    var status: String
    let last_updated: Int
    let form_id: UUID

    init(first_name: String, last_name: String, phoneNumber: String, status: String, form_id: UUID) {
        self.id = UUID()
        self.first_name = first_name
        self.last_name = last_name
        self.phoneNumber = phoneNumber
        self.status = status
        self.form_id = form_id
        self.last_updated = Int(Date().timeIntervalSince1970)
    }
    
}

struct SBMessage: Codable {
    let id: UUID
    var user_id: UUID
    var phoneNumber: String
    var message: String
    var useAttachment: Bool = false
    var attachmentType: String = ""
    var attachmentValue: String = ""

    init(user_id: UUID, phoneNumber: String, message: String, useAttachment: Bool = false, attachmentType: String = "", attachmentValue: String = "") {
        self.id = UUID()
        self.user_id = user_id
        self.phoneNumber = phoneNumber
        self.message = message
        self.useAttachment = useAttachment
        self.attachmentType = attachmentType
        self.attachmentValue = attachmentValue
    }
}

struct SBGif: Codable {
    let uuid: UUID
    let url: String
}

class SupabaseManager {
    static let shared = SupabaseManager()
    let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://blcsxzwsgjsgiewijdat.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJsY3N4endzZ2pzZ2lld2lqZGF0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgxOTIwNDUsImV4cCI6MjA1Mzc2ODA0NX0.QYkJgCst62KYHYRmkoZiDleexDraur3XWFP91TvYIAM"
    )

    func getID() async throws -> UUID {
        return try await supabase.auth.session.user.id
    }

    func getAPIKey() async throws -> String {
        let userID = try await getID()
        let query = try supabase.from("api_keys").select().eq("user_id", value: userID.uuidString)
        let response: [SBAPIKey] = try await query.execute().value
        return response.first!.key_value
    }

    func getUserForms() async throws -> [SBForm] {
        let userID = try await getID()
        let query = supabase.from("forms").select().eq("user_id", value: userID.uuidString)
        let response: [SBForm] = try await query.execute().value
        return response
    }

    func getForm(id: UUID) async throws -> SBForm {
        let query = supabase.from("forms").select()
        let response: [SBForm] = try await query.execute().value
        guard let form = response.first else {
            return SBForm(id: UUID(), name: "", message_template: "", autoFollowUp: true, user_id: UUID())
        }
        return form
    }

    func logout() async throws -> Void {
        try await supabase.auth.signOut()
    }

    func getGifs() async throws -> [SBGif] {
        let query = supabase.from("defaultGifs").select()
        let response: [SBGif] = try await query.execute().value
        return response
    }

   private func encodeToJSON<T: Encodable>(_ value: T) throws -> [String: String] {
    let encoder = JSONEncoder()
    // Use ISO8601 formatting for dates on JSON encoding
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(value)
    
    // Debug: print out the encoded JSON string.
    if let jsonString = String(data: data, encoding: .utf8) {
        print("Encoded JSON string: \(jsonString)")
    }
    
    // Convert data to a JSON object dictionary.
    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
    guard var dict = jsonObject as? [String: Any] else {
        throw NSError(domain: "Invalid json format", code: -1, userInfo: nil)
    }
    
    // Remove the id field.
    dict.removeValue(forKey: "id")
    
    var stringDict: [String: String] = [:]
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    for (key, value) in dict {
        // Skip NSNull values.
        if value is NSNull {
            continue
        }
        
        // If the value is already a String, check if it represents a date.
        if let dateString = value as? String,
           let date = ISO8601DateFormatter().date(from: dateString) {
            // Reformat the date string if you need the fractional seconds.
            stringDict[key] = isoFormatter.string(from: date)
        }
        // If the value is a Date, format it directly.
        else if let date = value as? Date {
            stringDict[key] = isoFormatter.string(from: date)
        }
        // For UUID, convert to string.
        else if let uuid = value as? UUID {
            stringDict[key] = uuid.uuidString
        }
        // Otherwise, just use the description.
        else {
            stringDict[key] = "\(value)"
        }
    }
    
    return stringDict
}



    func createForm(_ form: SBForm) async throws {
        print("Creating form with name: \(form.name)")
        
        do {
            let userID = try await getID()
            print("Retrieved user ID: \(userID)")
            
            // First encode to JSON to log the raw JSON string
            let jsonData = try JSONEncoder().encode(form)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Encoded JSON string: \(jsonString)")
            }
            
            var fields = try encodeToJSON(form)
            fields["user_id"] = userID.uuidString
            print("Encoded form fields: \(fields)")
            
            print("Executing insert query for form")
            let query = try supabase.from("forms").insert(fields)
            
            let res = try await query.execute().value
        } catch let error as DecodingError {
            print("Decoding error while creating form: \(error.localizedDescription)")
            print("Debug info: \(error)")
            throw error
        } catch {
            print("Error creating form: \(error)")
            throw error
        }
    }

    func updateForm(_ form: SBForm) async throws -> SBForm {
        let userID = try await getID()
        var fields = try encodeToJSON(form)
        fields["user_id"] = userID.uuidString
        
        let query = try supabase.from("forms")
            .update(fields)
            .eq("id", value: form.id)
        let response: [SBForm] = try await query.execute().value
        guard let updated = response.first else {
            return SBForm(id: UUID(), name: "", message_template: "", autoFollowUp: true, user_id: UUID())
        }
        return updated
    }
    
    func deleteForm(_ formID: UUID) async throws -> Void {
        let query = try supabase.from("forms").delete().eq("id", value: formID.uuidString)
        let _: [SBForm] = try await query.execute().value
    }
    
    func getFormFields(formID: UUID) async throws -> [SBFormField] {
        let query = supabase.from("form_fields").select().eq("form_id", value: formID.uuidString)
        let response: [SBFormField] = try await query.execute().value
        return response
    }

    func createFormField(_ formField: SBFormField) async throws {
        print("📝 Creating form field...")
        print("📋 Form field details:")
        print("   ID: \(formField.id)")
        print("   Name: \(formField.name)")
        print("   Form ID: \(formField.form_id)")
        
        do {
            let fields = try encodeToJSON(formField)
            print("🔄 Encoded JSON fields:")
            print("   \(fields)")
            
            let query = try supabase.from("form_fields").insert(fields)
            print("🚀 Executing insert query...")
            
            let res = try await query.execute().value
            print("✅ Form field created successfully")
            print("📊 Response data: \(res)")
        } catch let error as DecodingError {
            print("❌ JSON encoding error while creating form field:")
            print("   \(error.localizedDescription)")
            throw error
        } catch {
            print("❌ Error creating form field:")
            print("   \(error.localizedDescription)")
            throw error
        }
    }

    func updateFormField(_ formField: SBFormField) async throws -> SBFormField {
        let fields = try encodeToJSON(formField)
        let query = try supabase.from("form_fields")
            .update(fields)
            .eq("id", value: formField.id.uuidString)
        let response: [SBFormField] = try await query.execute().value
        guard let updated = response.first else {
            return SBFormField(id: UUID(), name: "", form_id: UUID())
        }
        return updated
    }

    func deleteFormField(_ formFieldID: UUID) async throws -> Void {
        let query = try supabase.from("form_fields").delete().eq("id", value: formFieldID.uuidString)
        let _: [SBFormField] = try await query.execute().value
    }

    func getAllContacts() async throws -> [SBContact] {
        let query = supabase.from("contacts").select()
        let response: [SBContact] = try await query.execute().value
        return response
    }

    func createContact(_ contact: SBContact) async throws -> SBContact {
        print(contact)
        let fields = try encodeToJSON(contact)
        print(fields)
        let query = try supabase.from("contacts").insert(fields).select()
        let response: [SBContact] = try await query.execute().value
        guard let created = response.first else {
            return SBContact(first_name: "", last_name: "", phoneNumber: "", status: "", form_id: UUID())
        }
        return SBContact(first_name: "", last_name: "", phoneNumber: "", status: "", form_id: UUID())
    }
    
    func updateContact(_ contact: SBContact) async throws -> SBContact {
        let fields = try encodeToJSON(contact)
        let query = try supabase.from("contacts")
            .update(fields)
            .eq("id", value: contact.id)
        let response: [SBContact] = try await query.execute().value
        guard let updated = response.first else {
            return SBContact(first_name: "", last_name: "", phoneNumber: "", status: "", form_id: UUID())
        }
        return updated
    }

    func deleteContact(_ contactID: UUID) async throws -> Void {
        let query = try supabase.from("contacts").delete().eq("id", value: contactID.uuidString)
        let _: [SBContact] = try await query.execute().value
    }

    func getMessages() async throws -> [SBMessage] {
        print("getting messages")
        let apiKey = try await getAPIKey()
        // Ensure we have a valid API key
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("not api key")
            return []
        }

        // Create URL with proper encoding
        guard let encodedKey = apiKey.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://api.goblue.app/v1/messages/\(encodedKey)") else {
            print("not url")
            return []
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
                print("not http response")
                return []
            }
            
            // Attempt to parse JSON response
                let decoder = JSONDecoder()
            print(data)
            print(String(data: data, encoding: .utf8)!)
                do {
                    let messages = try decoder.decode([SBMessage].self, from: data)
                    return messages
                } catch DecodingError.dataCorrupted(let context) {
                    print("Data corrupted: \(context.debugDescription)")
                    return []
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                    return []
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("Type mismatch for type \(type): \(context.debugDescription)")
                    return []
                } catch DecodingError.valueNotFound(let type, let context) {
                    print("Value of type \(type) not found: \(context.debugDescription)")
                    return []
                } catch {
                    print("Decoding error: \(error)")
                    return []
                }
            
        } catch URLError.timedOut {
            // Handle timeout specifically
            print("timeout")
            return []
            
        } catch URLError.notConnectedToInternet {
            // Handle no internet specifically  
            print("no internet")
            return []
            
        } catch {
            print(error.localizedDescription)
            // Handle all other errors
            return []
        }
    }

    func sendMessage(_ message: SBMessage) async throws -> SBMessage {
        let fields = try encodeToJSON(message)
        let query = try supabase.from("messages").insert(fields).select()
        let response: [SBMessage] = try await query.execute().value
        guard let created = response.first else {
            return SBMessage(user_id: UUID(), phoneNumber: "", message: "")
        }
        return created
    }

    func sendBulkMessages(_ messages: [SBMessage]) async throws -> [SBMessage] {
        let fields = try messages.map { try encodeToJSON($0) }
        let query = try supabase.from("messages").insert(fields).select()
        let response: [SBMessage] = try await query.execute().value
        return response
    }

    func createAPIKey(_ apiKey: SBAPIKey) async throws -> SBAPIKey {
        let fields = try encodeToJSON(apiKey)
        let query = try supabase.from("api_keys").insert(fields).select()
        let response: [SBAPIKey] = try await query.execute().value
        return response.first!
    }

    func getAPIKey(user_id: UUID) async throws -> SBAPIKey {
        let query = try supabase.from("api_keys").select().eq("user_id", value: user_id.uuidString)
        let response: [SBAPIKey] = try await query.execute().value
        return response.first!
    }

    func deleteAPIKey(_ apiKeyID: UUID) async throws -> Void {
        let query = try supabase.from("api_keys").delete().eq("id", value: apiKeyID.uuidString)
        let _: [SBAPIKey] = try await query.execute().value
    }
}
