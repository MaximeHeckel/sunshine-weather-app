//
//  LocationSearchService.swift
//  sunshine
//
//  Created by Maxime on 9/24/20.
//

import Foundation
import SwiftUI
import MapKit
import Combine

/**
 This location search service is based on https://www.mozzafiller.com/posts/mklocalsearchcompleter-swiftui-combine
 */

class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery = ""
    var completer: MKLocalSearchCompleter
    @Published var completions: [MKLocalSearchCompletion] = []
    var cancellable: AnyCancellable?
    
    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        cancellable = $searchQuery.assign(to: \.queryFragment, on: self.completer)
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError: Error) {
        // Set the results to empty in case the search query is empty or in case there's an uknown error
        self.completions = []
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.completions = completer.results
    }
}

extension MKLocalSearchCompletion: Identifiable {}
