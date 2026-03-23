//
//  PetEvolutionViewModel.swift
//  PetEvolution
//
//  Created by Zihan Li on 1/25/26.
//

import Foundation
import SwiftUI

@MainActor
class PetEvolutionViewModel: ObservableObject {
    @Published var currentStage: EvolutionStage = .configuration
    @Published var currentPet: Pet?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isServiceReachable: Bool = true
    @Published var isCheckingHealth: Bool = false

    // Configuration state
    @Published var selectedStyle: String = "gentle"
    @Published var selectedEvolutionPath: String = "gentle"
    @Published var colorPalette: String = "ocean blue"
    @Published var selectedAnimals: [String] = []

    // History
    @Published var petHistory: [Pet] = []

    private let service = PetEvolutionService.shared

    // MARK: - Health Check
    func checkHealth() async {
        isCheckingHealth = true
        while !Task.isCancelled {
            let result = await service.checkHealth()
            isServiceReachable = result
            if result {
                break
            }
            isCheckingHealth = false
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            isCheckingHealth = true
        }
        isCheckingHealth = false
    }

    // MARK: - Toggle Animal Selection
    func toggleAnimal(_ animal: String) {
        if let index = selectedAnimals.firstIndex(of: animal) {
            selectedAnimals.remove(at: index)
        } else {
            selectedAnimals.append(animal)
        }
    }

    // MARK: - Generate Pet
    func generatePet() async {
        guard !selectedAnimals.isEmpty else {
            errorMessage = "Please select at least one animal"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let pet = try await service.generatePet(
                style: selectedStyle,
                colorPalette: colorPalette,
                animals: selectedAnimals
            )
            currentPet = pet
            currentStage = .firstEvolution
            PetHistoryStore.shared.save(pet)
        } catch {
            errorMessage = "Failed to generate pet: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Evolve Pet
    func evolvePet() async {
        guard let pet = currentPet else { return }

        isLoading = true
        errorMessage = nil

        do {
            let evolvedPet = try await service.evolvePet(pet: pet, evolutionPath: selectedEvolutionPath)
            currentPet = evolvedPet
            PetHistoryStore.shared.save(evolvedPet)

            switch currentStage {
            case .firstEvolution:
                currentStage = .finalEvolution
            case .finalEvolution:
                currentStage = .complete
            default:
                break
            }
        } catch {
            errorMessage = "Failed to evolve pet: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - History
    func loadHistory() {
        petHistory = PetHistoryStore.shared.loadAll()
    }

    // MARK: - Reset to Start
    func reset() {
        currentStage = .configuration
        currentPet = nil
        errorMessage = nil
        selectedStyle = "gentle"
        selectedEvolutionPath = "gentle"
        colorPalette = "ocean blue"
        selectedAnimals = []
    }
}
