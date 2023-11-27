//
//  MapView.swift
//  ExpenseTracker
//
//  Created by Taher on 18/11/23.
//

import SwiftUI
import MapKit

/// This view shows the current position of user in Apple  map
struct CurrentLocationView: View {

    @Binding private var mapRegion: MKCoordinateRegion

    var body: some View {
        Map(
            coordinateRegion: $mapRegion,
            showsUserLocation: true
        )
    }

    init(mapRegion: Binding<MKCoordinateRegion>) {
        _mapRegion = mapRegion
    }
}
