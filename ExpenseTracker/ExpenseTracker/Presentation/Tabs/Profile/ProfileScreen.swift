//
//  ProfileScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 18/12/23.
//

import SwiftUI

struct ProfileScreen: View {

    @EnvironmentObject var navigator: AppCoordinatorViewModel
    @ObservedObject private var viewModel: ProfileScreenViewModel

    private let onSignOutSuccess: () -> Void

    private var budgetSectionView: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Text(Constants.AppText.monthlyBudget)
                .font(.title3)

            HStack {
                Text(Constants.AppText.budgetAmount)
                Spacer()
                TextField("0.00", text: $viewModel.budgetAmount)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 140.0)
            }

            HStack {
                Text(Constants.AppText.selectCurrency)
                Spacer()
                CurrencyPickerView(
                    currencyList: Constants.AppData.currencyList,
                    selectedCurrency: $viewModel.selectedCurrency
                )
            }

            DatePicker(
                selection: $viewModel.selectedDate,
                displayedComponents: .date
            ) {
                Text(Constants.AppText.selectDate)
            }
            .onChange(of: viewModel.selectedDate) { _ in
                viewModel.onSelectedDateChanged()
            }

            Text(
                DateFormatter.budgetDateFormat.string(
                    from: viewModel.selectedDate
                )
            )
            .font(.system(size: 12.0))
            .foregroundColor(.gray)

            saveBudgetButton
        }
        .padding(12.0)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12.0)
    }

    private var saveBudgetButtonTitle: String {
        viewModel.budgetProgressUIModel != nil ?
        Constants.AppText.updateBudget :
        Constants.AppText.saveBudget
    }

    private var saveBudgetButton: some View {
        Button {
            hideKeyboard()
            viewModel.onTapSaveBudget()
        } label: {
            Text(saveBudgetButtonTitle)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: Constants.AppColors.blueButtonColor),
                textColor: .white
            )
        )
    }

    private var signOutButton: some View {
        Button {
            viewModel.onTapSignOut()
        } label: {
            Text(Constants.AppText.signOut)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: Constants.AppColors.redButtonColor),
                textColor: .white
            )
        )
    }

    private var searchLocationButton: some View {
        Button {
            navigator.goToSearchLocationView()
        } label: {
            Text(Constants.AppText.searchLocationMap)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: Constants.AppColors.blueButtonColor),
                textColor: .white
            )
        )
    }

    private var seeCurrentLocationButton: some View {
        Button {
            navigator.goToCurrentLocationView()
        } label: {
            Text(Constants.AppText.seeCurrentLocationMap)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: Constants.AppColors.blueButtonColor),
                textColor: .white
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text(viewModel.user.name)
                        .font(.title2)
                        .padding(.bottom, 2)
                    Text(viewModel.user.email)
                        .padding(.bottom, 8)

                    if viewModel.budgetProgressUIModel != nil {
                        BudgetProgressView(
                            viewModel: viewModel,
                            onTapFilterExpenses: {
                                viewModel.onTapViewBudgetExpenses()
                            },
                            onTapUpdateBudget: {
                                viewModel.onTapUpdateBudget()
                            }
                        )
                        .padding(.bottom, 16)

                        if viewModel.isUpdateBudgetVisible {
                            budgetSectionView
                                .padding(.bottom, 16)
                        }
                    } else {
                        budgetSectionView
                            .padding(.bottom, 16)
                    }
                    Spacer(minLength: 100)

                    VStack(spacing: 4) {
                        searchLocationButton
                        seeCurrentLocationButton
                        signOutButton
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(Constants.AppText.done) {
                        hideKeyboard()
                    }
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onChange(of: viewModel.authState) { state in
            if state == .signedOut {
                onSignOutSuccess()
            }
        }
        .alertView(
            isPresenting: $viewModel.isShowingAlert,
            title: viewModel.alertData.title,
            description: viewModel.alertData.description,
            isError: viewModel.alertData.isError,
            didTap: {
                viewModel.isShowingAlert = false
            }
        )
        .animation(.linear(duration: 0.2), value: viewModel.isShowingAlert)
        .sheet(
            isPresented: $viewModel.isBudgetExpenseSheetPresented,
            onDismiss: {
                viewModel.recalculateBudgetProgressFromSelectedItems()
            }
        ) {
            BudgetExpenseSheetView(viewModel: viewModel)
        }
    }

    init(viewModel: ProfileScreenViewModel, onSignOutSuccess: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onSignOutSuccess = onSignOutSuccess
    }
}
