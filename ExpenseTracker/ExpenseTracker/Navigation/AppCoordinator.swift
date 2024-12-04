//
//  AppCoordinator.swift
//  ExpenseTracker
//
//  Created by Taher on 28/11/23.
//

import FlowStacks
import SwiftUI

struct AppCoordinator: View {
    
    @StateObject var coordinator: AppCoordinatorViewModel

    var body: some View {
        Router($coordinator.routes) { screen, _  in
            switch screen {
            case .home(let viewModel):
                HomeScreen(
                    viewModel: viewModel,
                    onSignInSuccess: { user in
                        coordinator.goToTabScreen(user: user)
                    }
                )
            case .searchLocation(let viewModel):
                LocationSearchScreen(viewModel: viewModel)
            case .showCurrentLocation(let viewModel):
                CurrentLocationScreen(viewModel: viewModel)
            case .tabScreen(let user):
                TabScreen(user: user)
            case let .expenseHistoryDetails(viewModel):
                ExpenseHistoryDetailsScreen(
                    viewModel: viewModel,
                    onTapBack: {
                        coordinator.goBack()
                    }
                )
            case let .expenseAnalysisDetails(viewModel):
                ExpenseAnalysisDetailsScreen(viewModel: viewModel)
            }
        }
        .environmentObject(coordinator)
    }
    
    init(coordinator: AppCoordinatorViewModel) {
        _coordinator = StateObject(wrappedValue: coordinator)
    }
}
