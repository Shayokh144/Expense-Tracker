//
//  Screen.swift
//  ExpenseTracker
//
//  Created by Taher on 28/11/23.
//

import Foundation

enum Screen {

    case home(HomeViewModel)
    case searchLocation(LocationSearchViewModel)
    case showCurrentLocation(CurrentLocationViewModel)
}
