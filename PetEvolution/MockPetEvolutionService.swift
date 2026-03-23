//
//  MockPetEvolutionService.swift
//  PetEvolution
//
//  Created by Zihan Li on 1/25/26.
//
//  NOTE: This service is no longer used. The app now connects directly
//  to the real backend at http://10.0.0.131:3001.
//

import Foundation

class MockPetEvolutionService {
    static let shared = MockPetEvolutionService()
    private init() {}
}
