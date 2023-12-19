//
//  AppCoordinator.swift
//  ExpenseTracker
//
//  Created by Taher on 28/11/23.
//

import FlowStacks
import SwiftUI

struct AppCoordinator: View {
    
    @ObservedObject var coordinator: AppCoordinatorViewModel

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
            }
        }
        .environmentObject(coordinator)
    }
}
