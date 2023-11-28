//
//  HomeScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 13/11/23.
//

import FlowStacks
import MapKit
import SwiftUI

struct CurrentLocationScreen: View {

    @EnvironmentObject var navigator: AppCoordinatorViewModel

    @ObservedObject private var viewModel: CurrentLocationViewModel
    @State var shouldShowMapView: Bool = false
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    var body: some View {
        VStack {
            Text(viewModel.addressString)
            Button {
                let currentLocation = viewModel.getCurrentLocation()
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // BACK BUTTON
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    navigator.goBack()
                }) {
                    Label("Back", systemImage: "arrow.left.circle")
                }
            }
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
        .sheet(isPresented: $shouldShowMapView) {
            CurrentLocationView(mapRegion: $region)
            .presentationDetents([.fraction(0.75)])
        }

    }

    init(viewModel: CurrentLocationViewModel) {
        self.viewModel = viewModel
    }
}
