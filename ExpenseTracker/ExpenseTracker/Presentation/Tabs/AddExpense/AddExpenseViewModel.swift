//
//  AddExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 27/12/23.
//

import Combine
import Foundation

final class AddExpenseViewModel: ObservableObject {

    private let firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase
    private let geminiExpenseParseUseCase: GeminiExpenseParseUseCase
    private var notesContextCache: [ExpenseParseContextItem]?

    @Published private(set) var addedLocalExpenseList: [Expense]
    @Published private(set) var currentTotal: Double
    @Published private(set) var state: State
    @Published private(set) var isParsingNotes = false
    @Published private(set) var addEntry: AddEntry = .options
    @Published var selectedCurrency: String
    @Published var selectedDate = Date.now

    @Published var editName: String = ""
    @Published var editPrice: String = ""
    @Published var editType: String = ""
    @Published var editPlace: String = ""
    @Published var editCountry: String = ""
    @Published var editCity: String = ""
    @Published var isShowingAlert: Bool = false
    @Published var alertData = AlertUIModel(title: "", description: "", isError: true)
    @Published var notesInputText = ""
    @Published var isShowingNotesInput = false

    init(
        firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase = FirebaseRealtimeDBUseCase.shared,
        geminiExpenseParseUseCase: GeminiExpenseParseUseCase = .shared
    ) {
        self.firebaseRealtimeDBUseCase = firebaseRealtimeDBUseCase
        self.geminiExpenseParseUseCase = geminiExpenseParseUseCase
        addedLocalExpenseList = []
        currentTotal = 0.0
        state = .add
        selectedCurrency = Constants.AppData.currencyList.first ?? "THB"
    }

    func saveExpenseList() {
        if !addedLocalExpenseList.isEmpty {
            let expenseList = createExpenseList()
            firebaseRealtimeDBUseCase.postExpanse(
                expenseList: expenseList
            ) { [weak self] isSuccess in
                NSLog("XYZ POST RESULT: \(isSuccess)")
                self?.notesContextCache = nil
                if isSuccess {
                    self?.addedLocalExpenseList.removeAll()
                    self?.currentTotal = 0.0
                    self?.addEntry = .options
                }
                self?.showAlert(
                    title: isSuccess ? "Success!" : "Error!",
                    description: isSuccess
                        ? Constants.AppText.expenseListAddSuccess
                        : Constants.AppText.expenseListAddFailed,
                    isError: !isSuccess
                )
            }
        }
    }

    func onAddLocalExpense(expense: Expense) {
        addedLocalExpenseList.append(expense)
        updateCurrentTotal()
    }

    func onTapEditButton(expense: Expense) {
        editName = expense.name
        editPrice = expense.price.fractionTwoDigitString
        editType = expense.type
        editPlace = expense.place
        editCity = expense.city
        editCountry = expense.country
        state = .edit(expense)
    }

    func onSaveEditExpense(expense: Expense) {
        if let editIndex = addedLocalExpenseList.firstIndex(where: { $0.id == expense.id }) {
            addedLocalExpenseList[editIndex].name = editName
            addedLocalExpenseList[editIndex].price = Double(editPrice) ?? 0.0
            addedLocalExpenseList[editIndex].type = editType
            addedLocalExpenseList[editIndex].place = editPlace
            addedLocalExpenseList[editIndex].city = editCity
            addedLocalExpenseList[editIndex].country = editCountry
        }
        updateCurrentTotal()
        state = .add
    }

    func onTapAddFromNotes() {
        isShowingNotesInput = true
    }

    func onTapAddManually() {
        addEntry = .manual
    }

    func onTapAddMore() {
        addEntry = .options
    }

    func onCancelManualInput() {
        addEntry = addedLocalExpenseList.isEmpty ? .options : .compact
    }

    func createListFromNotes() {
        let note = notesInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !note.isEmpty else {
            showAlert(
                title: "Error!",
                description: Constants.AppText.notesEmpty,
                isError: true
            )
            return
        }
        guard !isParsingNotes else {
            return
        }
        isParsingNotes = true
        Task { [weak self] in
            await self?.parseNotes(note)
        }
    }

    private func parseNotes(_ note: String) async {
        do {
            let context = await loadNotesContext()
            let expenses = try await geminiExpenseParseUseCase.parse(
                note: note,
                context: context
            )
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.isParsingNotes = false
                guard !expenses.isEmpty else {
                    self.showAlert(
                        title: "Error!",
                        description: Constants.AppText.notesNoItems,
                        isError: true
                    )
                    return
                }
                self.addedLocalExpenseList.append(contentsOf: expenses)
                self.updateCurrentTotal()
                self.notesInputText = ""
                self.isShowingNotesInput = false
                self.addEntry = .compact
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.isParsingNotes = false
                self?.showAlert(
                    title: "Error!",
                    description: GeminiExpenseParseUseCase.isServiceBusy(error)
                        ? Constants.AppText.notesServiceBusy
                        : Constants.AppText.notesParseFailed,
                    isError: true
                )
            }
        }
    }

    private func loadNotesContext() async -> [ExpenseParseContextItem] {
        if let notesContextCache {
            return notesContextCache
        }
        let lists = await firebaseRealtimeDBUseCase.getExpenseListsFromPreviousMonthStart()
        let context = GeminiExpenseParseUseCase.compactContext(from: lists)
        await MainActor.run { [weak self] in
            self?.notesContextCache = context
        }
        return context
    }

    private func createExpenseList() -> ExpenseList {
        let dateTime = DateFormatter.fullDateTimeFormat.string(from: selectedDate)
        let country = addedLocalExpenseList.first?.country ?? "Unknown"
        return .init(
            dateTime: dateTime,
            totalCost: currentTotal,
            country: country,
            currency: selectedCurrency,
            expenses: addedLocalExpenseList
        )
    }

    private func updateCurrentTotal() {
        currentTotal = addedLocalExpenseList.map(\.price).reduce(0.0, +)
    }

    private func showAlert(title: String, description: String, isError: Bool) {
        alertData = .init(
            title: title,
            description: description,
            isError: isError
        )
        isShowingAlert = true
    }
}

extension AddExpenseViewModel {

    enum State {
        case add
        case edit(Expense)
    }

    enum AddEntry: Equatable {
        case compact
        case options
        case manual
    }
}
