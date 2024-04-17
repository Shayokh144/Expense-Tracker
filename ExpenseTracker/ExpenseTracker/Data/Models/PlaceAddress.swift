//
//  PlaceAddress.swift
//  ExpenseTracker
//
//  Created by Taher on 10/1/24.
//

import Foundation

struct PlaceAddress: Hashable, Identifiable {

    var id: String {
        String(longitude ?? 0.0)
    }
    let name: String
    let city: String
    let country: String
    let longitude: Double?
    let latitude: Double?
}
