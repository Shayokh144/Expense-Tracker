//
//  AppCoordinatorViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 28/11/23.
//

import FlowStacks
import SwiftUI

final class AppCoordinatorViewModel: ObservableObject {

    @Published var routes: Routes<Screen>

    init() {
        self.routes = [.root(.home(HomeViewModel()))]
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
}
