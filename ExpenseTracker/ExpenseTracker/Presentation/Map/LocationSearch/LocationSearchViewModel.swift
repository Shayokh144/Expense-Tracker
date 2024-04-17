//
//  LocationSearchViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 22/11/23.
//

import Combine
import Foundation
import MapKit

final class LocationSearchViewModel: NSObject, ObservableObject {

    @Published var searchText: String = ""
    @Published private(set) var searchResults: [MKLocalSearchCompletion] = []
    
    private var cancellable: AnyCancellable?
    private let searchCompleter: MKLocalSearchCompleter!

    init(searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()) {
            self.searchCompleter = searchCompleter
            super.init()
            self.searchCompleter.delegate = self

            cancellable = $searchText
                .receive(on: DispatchQueue.main)
                .debounce(for: .milliseconds(650), scheduler: RunLoop.main, options: nil)
                .sink(receiveValue: { fragment in
                    if !fragment.isEmpty {
                        self.searchCompleter.queryFragment = fragment
                    } else {
                        self.searchResults = []
                    }
            })
    }

    func onTapPlaceSearchResult(result: MKLocalSearchCompletion) {
        // Form an MKLocalSearchRequest from MKLocalSearchCompletion
        let searchRequest = MKLocalSearch.Request(completion: result)

        // Create an MKLocalSearch with the search request
        let localSearch = MKLocalSearch(request: searchRequest)

        // Perform the search
        localSearch.start { (response, error) in
            if let error = error {
                print("Error performing local search: \(error.localizedDescription)")
                return
            }

            if let mapItems = response?.mapItems {
                // Handle the search results (mapItems) as needed
                for mapItem in mapItems {
                    print("Place Name: \(mapItem.name ?? "N/A")")
                    print("Coordinate: \(mapItem.placemark.coordinate)")
//                    print("Country: \(mapItem.placemark.country)")
//                    print("City: \(mapItem.placemark.locality)")
                    // Add more details based on your requirements
                }
            }
        }
    }
}

extension LocationSearchViewModel: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
//        for data in completer.results {
//            print("TITLE: \(data.title)")
//            print("SUB: \(data.subtitle)")
//            let components = data.subtitle.components(separatedBy: ", ")
//
//            // Remove the code like "10270" using regular expression
//            let cleanedComponents = components.map { component in
//                return component.replacingOccurrences(of: "\\b\\d{5}\\b", with: "", options: .regularExpression)
//            }
//
//            // Extract the last two items
//            if cleanedComponents.count >= 2 {
//                let lastItem = cleanedComponents[cleanedComponents.count - 1]
//                let secondLastItem = cleanedComponents[cleanedComponents.count - 2]
//
//                // Now, you can use lastItem and secondLastItem as needed
//                print("Last Item: \(lastItem)")
//                print("Second Last Item: \(secondLastItem)")
//            } else {
//                print("Not enough components in the address")
//            }
//        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("LocationSearchViewModel error: \(error)")
    }
}
