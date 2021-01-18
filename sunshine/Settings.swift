//
//  Settings.swift
//  sunshine
//
//  Created by Maxime on 9/20/20.
//

import SwiftUI
import MapKit

enum Section: Int{
    case locations = 0
    case settings = 1
}

struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct SettingsView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Temperature")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Picker(selection: $viewModel.temperature, label: Text("Temperature"), content: {
                    Text("Fahrenheit °F 🇺🇸").tag(Temperature.fahrenheit)
                    Text("Celsius °C 🌍").tag(Temperature.celsius)
                    Text("Kelvin °K 🤓").tag(Temperature.kelvin)
                })
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.top, 20)
            VStack {
                HStack {
                    Text("Wind Speed")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Picker(selection: $viewModel.speed, label: Text("Speed"), content: {
                    Text("mph 🇺🇸").tag(Speed.mph)
                    Text("km/h 🌍").tag(Speed.kmh)
                    Text("m/s 🤓").tag(Speed.mps)
                })
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.top, 20)
        }
        .padding([.leading, .trailing], 12)
    }
}

struct SheetPane: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: ViewModel
    
    @ObservedObject var locationSearchService: LocationSearchService
    var savedLocations: FetchedResults<Location>

    @State private var isSearchToggled = false
    @State private var selection = Section.locations
    
    var currentTitles: [String] {
        savedLocations.map { $0.title! }
    }
    
    var body: some View {
         ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial)).ignoresSafeArea(.all)
            VStack {
                Picker(selection: $selection, label: Text(""), content: {
                    Text("Locations").tag(Section.locations)
                    Text("Settings").tag(Section.settings)
                    
                })
                .pickerStyle(SegmentedPickerStyle())
                .padding([.leading, .trailing], 100)
                
                if(selection == Section.settings) {
                    GeometryReader { _ in
                        SettingsView()
                    }
                }
                
                if(selection == Section.locations) {
                    GeometryReader { geometry in
                        // If Search is not toggled: show the list of saved locations
                        if (!isSearchToggled) {
                            VStack {
                                VStack {
                                    HStack {
                                        Text("Your saved locations (\(savedLocations.count)/10)")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding([.leading, .trailing], 12)
                                    .padding(.top, 20)
                                    .padding(.bottom, 10)
                                    
                                    List {
                                        ForEach(savedLocations) { item in
                                            Text(item.name ?? "")
                                        }
                                        .onDelete(perform: removeLocation)
                                        .listRowBackground(Color.clear)
                                    }
                                }
                                Button(action: {
                                    self.isSearchToggled = true
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 18, weight: .medium))
                                    Text("Add locations")
                                }
                                .disabled(savedLocations.count >= 10)
                                .padding(.bottom, 10)
                            }
                            // If search is toggled: show the search locations view
                        } else {
                            VStack {
                                SearchBar(text: $locationSearchService.searchQuery, toggled: $isSearchToggled)
                                // If there are no items in the results of the search query (completion) AND if the search query is not empty, show the empty state
                                if (locationSearchService.completions.count == 0 && locationSearchService.searchQuery != "" ) {
                                    Spacer()
                                    Text("No results found.")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    // Else show the list
                                } else {
                                    List {
                                        ForEach(locationSearchService.completions, id: \.self) { completion in
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text(completion.title)
                                                    // If this completion is not yet added in the locations array, add the Add Location button
                                                    if (!currentTitles.contains(completion.title)) {
                                                        Spacer()
                                                        Button(action: {
                                                            addLocation(completion)
                                                        }) {
                                                            Image(systemName: "plus")
                                                        }
                                                        // Else show a checkmark to tell the user this view has already been added
                                                    } else {
                                                        Spacer()
                                                        Image(systemName: "checkmark")
                                                        
                                                    }
                                                }
                                            }
                                            .padding([.leading, .trailing], 10)
                                        }
                                        .listRowBackground(Color.clear)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding([.top], 20)
        }
        .onAppear {
            UITableView.appearance().backgroundColor = UIColor.clear
            UITableViewCell.appearance().backgroundColor = UIColor.clear
        }
        .background(BackgroundClearView())
    }
    
    func addLocation(_ completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let coordinate = response?.mapItems[0].placemark.coordinate else {
                return
            }
            
            guard let name = response?.mapItems[0].name else {
                return
            }
            
            let lat = coordinate.latitude
            let lon = coordinate.longitude
            
            let newSavedLocation = Location(context: viewContext)
            newSavedLocation.name = name
            newSavedLocation.title = completion.title
            newSavedLocation.lat = lat
            newSavedLocation.lon = lon
            newSavedLocation.id = UUID()
            newSavedLocation.timestamp = Date()
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func removeLocation(at offsets: IndexSet) {
        viewModel.items.remove(atOffsets: offsets)
        offsets.map { savedLocations[$0] }.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
