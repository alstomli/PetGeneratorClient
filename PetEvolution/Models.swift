//
//  Models.swift
//  PetEvolution
//
//  Created by Zihan Li on 1/25/26.
//

import Foundation

// MARK: - Evolution Stage
enum EvolutionStage {
    case configuration  // Step 1: Configure pet (style, colors, animals)
    case firstEvolution // Step 2: First evolution
    case finalEvolution // Step 3: Final evolution
    case complete       // Evolution complete
}

// MARK: - Augment Model
struct Augment: Codable {
    let id: String
    let name: String
    let category: String?
    let weight: Int?
    let story: String?
    let visualEffects: [String]?
}

// MARK: - Pet Model
struct Pet: Identifiable, Codable {
    let id: String
    let stage: Int
    let maxStages: Int
    let imageUrl: String
    let style: String?
    let colorPalette: String?
    let animals: [String]?
    let prompt: String?
    let metadata: String?
    let augments: [Augment]
    let evolutionPath: String?
    let provider: String?

    enum CodingKeys: String, CodingKey {
        case id, stage, maxStages, imageUrl, style, colorPalette, animals
        case prompt, metadata, augments, evolutionPath, provider
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        stage = try container.decode(Int.self, forKey: .stage)
        maxStages = try container.decode(Int.self, forKey: .maxStages)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        style = try container.decodeIfPresent(String.self, forKey: .style)
        colorPalette = try container.decodeIfPresent(String.self, forKey: .colorPalette)
        animals = try container.decodeIfPresent([String].self, forKey: .animals)
        prompt = try container.decodeIfPresent(String.self, forKey: .prompt)
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        augments = (try? container.decode([Augment].self, forKey: .augments)) ?? []
        evolutionPath = try container.decodeIfPresent(String.self, forKey: .evolutionPath)
        provider = try container.decodeIfPresent(String.self, forKey: .provider)
    }
}
