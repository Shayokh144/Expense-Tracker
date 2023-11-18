//
//  MapView.swift
//  ExpenseTracker
//
//  Created by Taher on 18/11/23.
//

import SwiftUI
import MapKit

struct MapView: View {

    @Binding private var mapRegion: MKCoordinateRegion

    var body: some View {
        Map(
            coordinateRegion: $mapRegion,
            showsUserLocation: true
            // userTrackingMode: .constant(.follow)
        )
    }

    init(mapRegion: Binding<MKCoordinateRegion>) {
        _mapRegion = mapRegion
    }
}
