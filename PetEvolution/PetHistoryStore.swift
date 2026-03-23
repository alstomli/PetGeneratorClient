//
//  PetHistoryStore.swift
//  PetEvolution
//

import Foundation

class PetHistoryStore {
    static let shared = PetHistoryStore()

    private let directory: URL

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        directory = docs.appendingPathComponent("pet-history", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func save(_ pet: Pet) {
        let url = directory.appendingPathComponent("\(pet.id).json")
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(pet) {
            try? data.write(to: url)
        }
    }

    func loadAll() -> [Pet] {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ) else { return [] }

        let decoder = JSONDecoder()
        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { try? decoder.decode(Pet.self, from: Data(contentsOf: $0)) }
            .sorted { $0.id > $1.id }
    }

    func delete(_ pet: Pet) {
        let url = directory.appendingPathComponent("\(pet.id).json")
        try? FileManager.default.removeItem(at: url)
    }
}
