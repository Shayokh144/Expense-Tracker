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
}

extension LocationSearchViewModel: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("LocationSearchViewModel error: \(error)")
    }
}
