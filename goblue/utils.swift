//
//  utils.swift
//  goblue
//
//  Created by Joshua Riley on 11/02/2025.
//

import SwiftUI
import Foundation

func toPascalCase(_ input: String) -> String {
    // Split the string by any non-alphanumeric characters
    let words = input.components(separatedBy: CharacterSet.alphanumerics.inverted)
    
    // Capitalize first letter of each word and join, except first word
    return words.enumerated().map { index, word -> String in
        guard !word.isEmpty else { return "" }
        if index == 0 {
            return word.lowercased()
        }
        let firstChar = word.prefix(1).uppercased()
        let remainingChars = word.dropFirst().lowercased()
        return firstChar + remainingChars
    }.joined()
}

func fromPascalCase(_ input: String) -> String {
    // Add a space before each capital letter (except the first one)
    let pattern = "(?<!^)(?=[A-Z])"
    let words = input.split(separator: " ", omittingEmptySubsequences: false)
    
    return words.map { word in
        guard !word.isEmpty else { return "" }
        // Split on capital letters and join with spaces
        let separated = word.replacingOccurrences(of: pattern, with: " ", options: .regularExpression)
        // Capitalize first letter of each word
        return separated.split(separator: " ").map { word in
            guard !word.isEmpty else { return "" }
            return word.prefix(1).uppercased() + word.dropFirst().lowercased()
        }.joined(separator: " ")
    }.joined(separator: " ")
}
