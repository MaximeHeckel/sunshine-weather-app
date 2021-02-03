//
//  SearchBar.swift
//  sunshine
//
//  Created by Maxime on 9/24/20.
//

import SwiftUI


/**
 This search bar element is based on https://www.mozzafiller.com/posts/mklocalsearchcompleter-swiftui-combine
 */

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    @Binding var toggled: Bool

    class Coordinator: NSObject, UISearchBarDelegate {
        
        @Binding var text: String
        @Binding var toggled: Bool
        
        init(text: Binding<String>, toggled: Binding<Bool>) {
            _text = text
            _toggled = toggled
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
             searchBar.setShowsCancelButton(true, animated: true)
             toggled = true
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
             searchBar.resignFirstResponder()
             searchBar.setShowsCancelButton(false, animated: true)
             toggled = false
        }

    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, toggled: $toggled)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Enter a city name e.g. New York"
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.becomeFirstResponder()
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

