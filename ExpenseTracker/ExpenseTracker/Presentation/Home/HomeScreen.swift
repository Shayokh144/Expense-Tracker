//
//  HomeScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 13/11/23.
//

import MapKit
import SwiftUI

struct HomeScreen: View {

    @ObservedObject private var viewModel: HomeViewModel
    @State var shouldShowMapView: Bool = false
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    var body: some View {
        VStack {
            Text(viewModel.addressString)
            Button {
                let currentLocation = viewModel.getCurrentLocation()
                print("XYZ \(currentLocation)")
                region = MKCoordinateRegion(
                    center: currentLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                )
                shouldShowMapView.toggle()
            } label: {
                Text("Show map view")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            viewModel.viewDidAppear()
        }
        .sheet(isPresented: $shouldShowMapView) {
            MapView(mapRegion: $region)
            .presentationDetents([.fraction(0.75)])
        }

    }

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
}
