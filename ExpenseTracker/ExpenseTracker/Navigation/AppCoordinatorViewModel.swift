//
//  AppCoordinatorViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 28/11/23.
//

import Combine
import FlowStacks
import SwiftUI

final class AppCoordinatorViewModel: ObservableObject {

    @Published var routes: Routes<Screen>

    init() {
        self.routes = [.root(.home(HomeViewModel()), embedInNavigationView: true)]
    }

    func goBack() {
        routes.goBack()
    }

    func goBackToRoot() {
        routes.goBackToRoot()
    }

    func goToSearchLocationView() {
        routes.presentCover(
            .searchLocation(LocationSearchViewModel()),
            embedInNavigationView: true
        )
    }
    
    func goToCurrentLocationView() {
        routes.presentCover(
            .showCurrentLocation(CurrentLocationViewModel()),
            embedInNavigationView: true
        )
    }

    func goToTabScreen(user: User) {
        routes = [.root(.tabScreen(user), embedInNavigationView: true)]
    }

    func goToHome() {
        routes = [.root(.home(HomeViewModel()), embedInNavigationView: true)]
    }
    
    func goToExpenseHistoryDetailsView(viewModel: ExpenseHistoryDetailsViewModel) {
        RouteSteps.withDelaysIfUnsupported(self, \.routes) {
          $0.push(.expenseHistoryDetails(viewModel))
        }
    }
}
