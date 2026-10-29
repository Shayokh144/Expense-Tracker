//
//  GeminiExpenseParseUseCase.swift
//  ExpenseTracker
//
//  Created by Taher on 2/9/26.
//

import FirebaseAI
import Foundation

struct ExpenseParseContextItem: Codable, Hashable {

    let name: String
    let type: String
    let place: String
    let city: String
    let country: String
}

final class GeminiExpenseParseUseCase {

    static let shared = GeminiExpenseParseUseCase()

    private let decoder = JSONDecoder()

    private init() {}

    func parse(
        note: String,
        context: [ExpenseParseContextItem]
    ) async throws -> [Expense] {
        let prompt = makePrompt(note: note, context: context)
        var lastError: Error?
        for modelName in Constants.Gemini.modelNames {
            NSLog("[AddFromNotes] Trying model: \(modelName)")
            let model = makeModel(modelName: modelName)
            do {
                let response = try await generateContent(
                    modelName: modelName,
                    model: model,
                    prompt: prompt
                )
                guard let text = response.text, !text.isEmpty else {
                    throw CommonError.invalidData
                }
                let expenses = try decodeExpenses(from: text)
                NSLog(
                    "[AddFromNotes] Success with model: \(modelName) (\(expenses.count) expense(s))"
                )
                return expenses
            } catch {
                lastError = error
                NSLog(
                    "[AddFromNotes] Failed model: \(modelName) — \(Self.errorLogDescription(error))"
                )
                if shouldTryNextModel(after: error) {
                    NSLog("[AddFromNotes] Trying next fallback model")
                    continue
                }
                throw error
            }
        }
        NSLog("[AddFromNotes] All models failed")
        throw lastError ?? CommonError.unknown
    }

    private func generateContent(
        modelName: String,
        model: GenerativeModel,
        prompt: String
    ) async throws -> GenerateContentResponse {
        var lastError: Error?
        let maxAttempts = Constants.Gemini.maxRetries + 1
        for attempt in 0...Constants.Gemini.maxRetries {
            do {
                NSLog("[AddFromNotes] \(modelName) request \(attempt + 1)/\(maxAttempts)")
                return try await model.generateContent(prompt)
            } catch {
                lastError = error
                NSLog(
                    "[AddFromNotes] \(modelName) request \(attempt + 1) error: \(Self.errorLogDescription(error))"
                )
                guard shouldRetrySameModel(after: error), attempt < Constants.Gemini.maxRetries else {
                    throw error
                }
                let delaySeconds = (attempt + 1) * 2
                NSLog("[AddFromNotes] \(modelName) retrying in \(delaySeconds)s")
                let delayNanos = UInt64(delaySeconds) * 1_000_000_000
                try await Task.sleep(nanoseconds: delayNanos)
            }
        }
        throw lastError ?? CommonError.unknown
    }

    private static func errorLogDescription(_ error: Error) -> String {
        let message = errorMessage(error)
        if let httpStatus = httpStatus(in: message) {
            return "\(message) (HTTP \(httpStatus))"
        }
        let nsError = error as NSError
        return "\(message) (NSError \(nsError.domain) \(nsError.code))"
    }

    static func isServiceBusy(_ error: Error) -> Bool {
        shared.shouldTryNextModel(after: error)
    }

    /// Move to the next fallback model (429 quota is per-model; overload is often model-specific).
    private func shouldTryNextModel(after error: Error) -> Bool {
        if shouldRetrySameModel(after: error) {
            return true
        }
        let message = Self.errorMessage(error).lowercased()
        return message.contains("http 429")
            || message.contains("resource_exhausted")
            || message.contains("quota")
            || message.contains("rate limit")
            || message.contains("rate-limit")
    }

    /// Retry the same model after a short delay (not daily quota / per-model limit).
    private func shouldRetrySameModel(after error: Error) -> Bool {
        if let generateError = error as? GenerateContentError,
           case .internalError(let underlying) = generateError {
            return shouldRetrySameModel(after: underlying)
        }
        let message = Self.errorMessage(error).lowercased()
        if Self.isQuotaOrRateLimitError(error) {
            return Self.isShortRateLimit(error)
        }
        if let status = Self.httpStatus(in: message) {
            return status == 503 || status == 500
        }
        return message.contains("unavailable")
            || message.contains("deadline")
            || message.contains("high demand")
    }

    private static func errorMessage(_ error: Error) -> String {
        if let generateError = error as? GenerateContentError,
           case .internalError(let underlying) = generateError {
            return errorMessage(underlying)
        }
        return (error as NSError).localizedDescription
    }

    private static func httpStatus(in message: String) -> Int? {
        guard let range = message.range(of: "HTTP ") else {
            return nil
        }
        let suffix = message[range.upperBound...]
        let digits = suffix.prefix(while: { $0.isNumber })
        guard !digits.isEmpty, let code = Int(digits) else {
            return nil
        }
        return code
    }

    private static func isQuotaOrRateLimitError(_ error: Error) -> Bool {
        let message = errorMessage(error).lowercased()
        return message.contains("http 429")
            || message.contains("resource_exhausted")
            || message.contains("quota")
            || message.contains("rate limit")
            || message.contains("rate-limit")
    }

    /// True when the API suggests a sub-second/minute retry (not daily free-tier caps).
    private static func isShortRateLimit(_ error: Error) -> Bool {
        let message = errorMessage(error).lowercased()
        if message.contains("free_tier") || message.contains("perday") {
            return false
        }
        if message.contains("please retry in") {
            return true
        }
        return message.contains("rate limit") && !message.contains("quota exceeded")
    }

    static func compactContext(from expenseLists: [ExpenseList]) -> [ExpenseParseContextItem] {
        var seen = Set<ExpenseParseContextItem>()
        var items: [ExpenseParseContextItem] = []
        for list in expenseLists {
            for expense in list.expenses {
                let item = ExpenseParseContextItem(
                    name: expense.name,
                    type: expense.type,
                    place: expense.place,
                    city: expense.city,
                    country: expense.country
                )
                if seen.insert(item).inserted {
                    items.append(item)
                }
                if items.count >= Constants.Gemini.maxContextItems {
                    return items
                }
            }
        }
        return items
    }

    private func makeModel(modelName: String) -> GenerativeModel {
        let schema = Schema.object(
            properties: [
                "expenses": .array(
                    items: .object(
                        properties: [
                            "name": .string(),
                            "price": .double(),
                            "type": .string(),
                            "place": .string(),
                            "city": .string(),
                            "country": .string()
                        ]
                    )
                )
            ]
        )
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        return ai.generativeModel(
            modelName: modelName,
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: schema
            ),
            systemInstruction: ModelContent(
                role: "system",
                parts: TextPart(systemInstruction)
            )
        )
    }

    private var systemInstruction: String {
        """
        You parse personal expense notes into a JSON object with an "expenses" array.
        Fill name, price, type, place, city, and country for every item. Never leave fields empty.

        Line format:
        - The first number on the line is the price.
        - Text before the price is the name. Commas stay in the name (example: "egg, milk 200 7-11").
        - After the price: place, then optional type. Example: item name, price, place, type.

        Type:
        - If the user wrote a type, keep that type. Only fix spelling (for example "fod" → "food", "restaurent food" → "restaurant food").
        - If a similar past expense used that same type, copy the historical wording (for example user "food" and past "Food" → "Food").
        - Do not replace the user's type with a short category like Grocery, Housing, or Utility.
        - If they did not write a type, copy the type from the most similar known past expense.
        - If there is no similar past expense, infer a reasonable type from the item name using your knowledge.

        Place, city, country:
        - Prefer the most similar known past expense for place, city, country, and type when the note is incomplete.
        - Also use your geographic knowledge. If the user writes a city (for example Bangkok), set city to that city and country to the matching country (Thailand). Same for Dhaka → Bangladesh, and other well-known cities.
        - If after the price the user wrote a city name, treat it as city (and country from knowledge). Fill place from a similar past item when possible; otherwise use that city as place too.
        - If unknown, use your best guess from the note and world knowledge. Never leave fields empty.

        Example note:
        electric bill 500 Bangkok
        egg, milk 200 7-11
        biriyani, singara 400 neerja restaurent food

        Example JSON (Bangkok implies Thailand; user type "restaurent food" kept as "restaurant food"):
        {"expenses":[{"name":"electric bill","price":500,"type":"utility","place":"Aspire","city":"Bangkok","country":"Thailand"},{"name":"egg, milk","price":200,"type":"grocery","place":"7-11","city":"Bangkok","country":"Thailand"},{"name":"biriyani, singara","price":400,"type":"restaurant food","place":"neerja","city":"Bangkok","country":"Thailand"}]}
        """
    }

    private func makePrompt(note: String, context: [ExpenseParseContextItem]) -> String {
        let contextJSON: String
        if let data = try? JSONEncoder().encode(context),
           let json = String(data: data, encoding: .utf8) {
            contextJSON = json
        } else {
            contextJSON = "[]"
        }
        return """
        Known past expenses:
        \(contextJSON)

        Parse this note into expenses:
        \(note)
        """
    }

    private func decodeExpenses(from text: String) throws -> [Expense] {
        guard let data = text.data(using: .utf8) else {
            throw CommonError.invalidData
        }
        let parsed = try decoder.decode(ParsedExpenseList.self, from: data)
        let timestamp = DateFormatter.fullDateTimeFormat.string(from: Date())
        return parsed.expenses.enumerated().map { index, item in
            Expense(
                id: "\(timestamp)-\(index)",
                name: item.name,
                price: item.price,
                type: item.type,
                place: item.place,
                city: item.city,
                country: item.country
            )
        }
    }
}

private struct ParsedExpenseList: Decodable {

    let expenses: [ParsedExpense]
}

private struct ParsedExpense: Decodable {

    let name: String
    let price: Double
    let type: String
    let place: String
    let city: String
    let country: String
}
