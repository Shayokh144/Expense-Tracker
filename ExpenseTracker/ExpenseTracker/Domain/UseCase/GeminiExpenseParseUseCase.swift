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
        let model = makeModel()
        let prompt = makePrompt(note: note, context: context)
        let response = try await generateContent(model: model, prompt: prompt)
        guard let text = response.text, !text.isEmpty else {
            throw CommonError.invalidData
        }
        return try decodeExpenses(from: text)
    }

    private func generateContent(
        model: GenerativeModel,
        prompt: String
    ) async throws -> GenerateContentResponse {
        var lastError: Error?
        for attempt in 0...Constants.Gemini.maxRetries {
            do {
                return try await model.generateContent(prompt)
            } catch {
                lastError = error
                guard isRetryable(error), attempt < Constants.Gemini.maxRetries else {
                    throw error
                }
                let delayNanos = UInt64((attempt + 1) * 2) * 1_000_000_000
                try await Task.sleep(nanoseconds: delayNanos)
            }
        }
        throw lastError ?? CommonError.unknown
    }

    static func isServiceBusy(_ error: Error) -> Bool {
        shared.isRetryable(error)
    }

    private func isRetryable(_ error: Error) -> Bool {
        if let generateError = error as? GenerateContentError,
           case .internalError(let underlying) = generateError {
            return isRetryable(underlying)
        }
        let nsError = error as NSError
        if nsError.code == 503 {
            return true
        }
        let message = nsError.localizedDescription.lowercased()
        return message.contains("unavailable") || message.contains("deadline")
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

    private func makeModel() -> GenerativeModel {
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
            modelName: Constants.Gemini.modelName,
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
        Each note line is usually: item name, price, place.
        A name can contain commas, for example "egg, milk 200 7-11".
        Fill name, price, type, place, city, and country for every item.
        Use known past expenses to fill place, city, country, and type when the note is incomplete.
        Prefer the most similar past item. If unknown, use your best guess. Never leave fields empty.
        Use short types such as Grocery, Housing, Utility, Food, Transport, or Other.

        Example note:
        electric bill 500 Aspire
        egg, milk 200 7-11

        Example JSON:
        {"expenses":[{"name":"electric bill","price":500,"type":"Utility","place":"Aspire","city":"Bangkok","country":"Thailand"},{"name":"egg, milk","price":200,"type":"Grocery","place":"7-11","city":"Bangkok","country":"Thailand"}]}
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
