//
//  PetEvolutionService.swift
//  PetEvolution
//
//  Created by Zihan Li on 1/25/26.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int, body: String)
    case decodingError(String)
    case serverError(String)
    case imageDataError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse(let code, let body):
            return "Server returned \(code): \(body.prefix(300))"
        case .decodingError(let detail):
            return "JSON decode failed: \(detail)"
        case .serverError(let msg):
            return "Server error: \(msg)"
        case .imageDataError:
            return "Failed to decode pet image data"
        }
    }
}

class PetEvolutionService {
    static let shared = PetEvolutionService()

    let baseURL = "http://10.0.0.131:3001"

    private init() {}

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 120
        return URLSession(configuration: config)
    }()

    // MARK: - Health Check
    func checkHealth() async -> Bool {
        guard let url = URL(string: "\(baseURL)/api/health") else { return false }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { return false }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = json["status"] as? String {
                return status == "ok"
            }
            return false
        } catch {
            return false
        }
    }

    // MARK: - Generate Pet
    func generatePet(style: String, colorPalette: String, animals: [String], maxStages: Int = 3) async throws -> Pet {
        guard let url = URL(string: "\(baseURL)/api/google/generate-pet") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "style": style,
            "colorPalette": colorPalette,
            "animals": animals,
            "maxStages": maxStages
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        request.httpBody = bodyData

        let bodyString = String(data: bodyData, encoding: .utf8) ?? ""
        print("=== generatePet REQUEST ===")
        print("URL: \(url)")
        print("Method: POST")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Body:\n\(bodyString)")
        print("===========================")

        let (data, response) = try await session.data(for: request)

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        let responseBody = String(data: data, encoding: .utf8) ?? "(non-UTF8 body)"
        // Log response (truncate imageUrl to avoid flooding console)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            var truncated = json
            if let imgUrl = truncated["imageUrl"] as? String {
                truncated["imageUrl"] = "data:image/png;base64,... [\(imgUrl.count) chars]"
            }
            print("=== generatePet RESPONSE ===")
            print("Status: \(statusCode)")
            print("Keys: \(json.keys.sorted())")
            if let pretty = try? JSONSerialization.data(withJSONObject: truncated, options: .prettyPrinted),
               let str = String(data: pretty, encoding: .utf8) {
                print("Body (truncated):\n\(str)")
            }
            print("============================")
        } else {
            print("=== generatePet RESPONSE ===")
            print("Status: \(statusCode)")
            print("Body:\n\(responseBody.prefix(500))")
            print("============================")
        }

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse(statusCode: statusCode, body: responseBody)
        }

        do {
            return try JSONDecoder().decode(Pet.self, from: data)
        } catch let decodeError as DecodingError {
            switch decodeError {
            case .keyNotFound(let key, _):
                throw APIError.decodingError("Missing key: '\(key.stringValue)'")
            case .typeMismatch(let type, let ctx):
                let path = ctx.codingPath.map { $0.stringValue }.joined(separator: ".")
                throw APIError.decodingError("Type mismatch at '\(path)': expected \(type)")
            case .valueNotFound(let type, let ctx):
                let path = ctx.codingPath.map { $0.stringValue }.joined(separator: ".")
                throw APIError.decodingError("Value not found at '\(path)': expected \(type)")
            case .dataCorrupted(let ctx):
                throw APIError.decodingError("Data corrupted: \(ctx.debugDescription)")
            @unknown default:
                throw APIError.decodingError(decodeError.localizedDescription)
            }
        } catch let decodeError {
            throw APIError.decodingError(decodeError.localizedDescription)
        }
    }

    // MARK: - Evolve Pet
    func evolvePet(pet: Pet, evolutionPath: String) async throws -> Pet {
        guard let url = URL(string: "\(baseURL)/api/google/evolve-pet") else {
            throw APIError.invalidURL
        }

        // Decode base64 image: strip "data:image/...;base64," prefix
        let imageDataURL = pet.imageUrl
        guard let commaIndex = imageDataURL.firstIndex(of: ",") else {
            throw APIError.imageDataError
        }
        let base64String = String(imageDataURL[imageDataURL.index(after: commaIndex)...])
        guard let imageData = Data(base64Encoded: base64String) else {
            throw APIError.imageDataError
        }

        // Build description from prompt or fallback
        let description: String
        if let prompt = pet.prompt, !prompt.isEmpty {
            description = String(prompt.prefix(200))
        } else {
            description = "Stage \(pet.stage) \(pet.style ?? "gentle") pet"
        }

        // colorPalette fallback
        let colorPalette = pet.colorPalette ?? "vibrant colors"

        // metadata is a plain string from the API — pass through as-is
        let previousMetadata = pet.metadata ?? "{}"

        // Serialize augments array back to JSON string
        let augmentsJSON = (try? String(data: JSONEncoder().encode(pet.augments), encoding: .utf8)) ?? "[]"

        // Build multipart/form-data body
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = buildMultipartBody(
            boundary: boundary,
            fields: [
                ("petId", pet.id),
                ("currentStage", "\(pet.stage)"),
                ("maxStages", "\(pet.maxStages)"),
                ("description", description),
                ("evolutionPath", evolutionPath),
                ("colorPalette", colorPalette),
                ("previousMetadata", previousMetadata),
                ("augments", augmentsJSON)
            ],
            imageData: imageData,
            imageFieldName: "image",
            imageFilename: "pet.png",
            imageMimeType: "image/png"
        )

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let body = String(data: data, encoding: .utf8) ?? "(non-UTF8 body)"
            throw APIError.invalidResponse(statusCode: statusCode, body: body)
        }

        do {
            return try JSONDecoder().decode(Pet.self, from: data)
        } catch let decodeError {
            throw APIError.decodingError(decodeError.localizedDescription)
        }
    }

    // MARK: - Multipart Body Builder
    private func buildMultipartBody(
        boundary: String,
        fields: [(String, String)],
        imageData: Data,
        imageFieldName: String,
        imageFilename: String,
        imageMimeType: String
    ) -> Data {
        var body = Data()

        for (name, value) in fields {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(imageFieldName)\"; filename=\"\(imageFilename)\"\r\n")
        body.appendString("Content-Type: \(imageMimeType)\r\n\r\n")
        body.append(imageData)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")

        return body
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
