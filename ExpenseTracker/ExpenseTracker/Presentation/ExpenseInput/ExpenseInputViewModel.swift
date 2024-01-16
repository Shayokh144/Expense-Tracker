//
//  ExpenseInputViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 10/1/24.
//

import Combine
import Foundation
import MapKit

final class ExpenseInputViewModel: NSObject, ObservableObject {

    @Published var searchText: String = ""
    @Published private(set) var searchResults: [PlaceAddress] = []
    @Published var productName: String = ""
    @Published var productPrice: String = ""
    @Published var productType: String = ""
    @Published var place: String = ""
    @Published var selectedPlace: PlaceAddress? = nil

    private var cancellable: AnyCancellable?
    private let searchCompleter: MKLocalSearchCompleter!

    init(searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()) {
        self.searchCompleter = searchCompleter
        super.init()
        self.searchCompleter.delegate = self

        cancellable = $searchText
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main, options: nil)
            .sink(receiveValue: { fragment in
                if !fragment.isEmpty {
                    self.searchCompleter.queryFragment = fragment
                } else {
                    self.searchResults = []
                }
            })
    }

    func onTapPlaceSearchResult(result: PlaceAddress) {
        selectedPlace = result
    }

    func onTapChangeLocation() {
        selectedPlace = nil
    }

    func onTapAddExpense() -> Expense {
        let dateTime = DateFormatter.fullDateTimeFormat.string(from: Date())
        let expense = Expense(
            id: dateTime,
            name: productName,
            price: Double(productPrice) ?? 0.0,
            type: productType,
            place: selectedPlace?.name ?? "Unknown",
            city: selectedPlace?.city ?? "Unknown",
            country: selectedPlace?.country ?? "Unknown"
        )
        productName = ""
        productPrice = ""
        productType = ""
        return expense
    }
}

extension ExpenseInputViewModel: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults.removeAll()
        convertToPlaceAddressResult(Array(completer.results.prefix(5)))
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("LocationSearchViewModel error: \(error)")
    }

    private func convertToPlaceAddressResult(_ results: [MKLocalSearchCompletion]) {
        for result in results {
            let searchRequest = MKLocalSearch.Request(completion: result)
            let localSearch = MKLocalSearch(request: searchRequest)
            localSearch.start { [weak self] (response, error) in
                if let error = error {
                    print("Error performing local search: \(error.localizedDescription)")
                    return
                }
                if let mapItem = response?.mapItems.first {
                    let address = PlaceAddress(
                        name: mapItem.name ?? "No name",
                        city: mapItem.placemark.locality ?? "No city",
                        country: mapItem.placemark.country ?? "No country",
                        longitude: mapItem.placemark.coordinate.longitude,
                        latitude: mapItem.placemark.coordinate.latitude
                    )
                    self?.searchResults.append(address)
                }
            }
        }
    }
}
