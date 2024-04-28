//
//  Answer.swift
//  HangingSloth
//
//  Created by Rodrigo Cavalcanti on 27/04/24.
//

import Foundation

struct Answer: Codable {
    var word: String
    var hints: [String]
}

extension Answer {
    static let all: [Answer] = {
        let answersURL = Bundle.main.url(forResource: "Answers", withExtension: "json")
        let decoder = JSONDecoder()
        
        guard let answersURL,
              let data = try? Data(contentsOf: answersURL),
              let jsonPetitions = try? decoder.decode([Answer].self, from: data) else { return [] }
        
        return jsonPetitions
    }()
}

extension Answer {
    var enumeratedHints: [String] {
        hints.enumerated().map {
            "\($0.offset + 1). \($0.element)"
        }
    }
    
    var fullHint: String {
        let enumeratedHints = enumeratedHints.joined(separator: "\n")
        let hintsTitle = "Hints:\n"
        
        return hintsTitle + enumeratedHints
    }
}
