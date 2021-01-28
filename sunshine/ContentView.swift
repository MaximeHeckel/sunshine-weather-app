//
//  ContentView.swift
//  sunshine
//
//  Created by Maxime on 8/22/20.
//

import SwiftUI
import CoreData

let ANIMATIONS_QUEUE = DispatchQueue(label: "Animations",
                                     qos: .userInteractive,
                                     attributes: .concurrent,
                                     autoreleaseFrequency: .workItem)

let gradients: [MainDaypart: [Color]]! = [
    MainDaypart.dawn: [Color("Pink Dawn"), Color("Blue Dawn End Gradient")],
    MainDaypart.mid: [Color("Blue Mid Day"), Color("Blue Mid Day End Gradient")],
    MainDaypart.dusk: [Color("Blue Dusk"), Color("Peach Dusk End Gradient")],
    MainDaypart.night: [Color("Blue Night"),  Color("Blue Night End Gradient")]]

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = ViewModel()
    @State private var loading = false
    @State private var error = false
    @State private var isSheetPresented = false
    @State private var bottomSheetShown = false


    @FetchRequest(entity: Location.entity(),sortDescriptors: [NSSortDescriptor(keyPath: \Location.timestamp, ascending: true)], animation: .default)
    private var savedLocations: FetchedResults<Location>

    let client = WeatherAPIClient()

    let locationSearchService = LocationSearchService()
    // let refreshTimer = Timer.publish(every: TimeInterval(3600), on: .main, in: .common).autoconnect()


    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
                .edgesIgnoringSafeArea(.all)
            VStack {
                // Top Bar
                HStack {
                    Button(action: {
                        self.isSheetPresented.toggle()
                    }) {
                        if(colorScheme == .dark) {
                            Image("menu-light")
                        } else {
                            Image("menu-dark")
                        }
                    }
                    Spacer()
                }
                .padding([.top, .leading], 20)

                // Center and Bottom View
                GeometryReader { geometry in
                    if(savedLocations.count != 0 ){
                        ZStack {
                            TabView(selection: $viewModel.selectTabIndex){
                                ForEach(savedLocations.indices) { index in
                                    MainWeatherScreen(forecast: viewModel.focusedItem, isSelected: viewModel.selectTabIndex == index, name: savedLocations[index].name!, status: viewModel.state, tempUnit: viewModel.temperature, speedUnit: viewModel.speed)
                                        .tag(index)
                                }
                            }
                            .onReceive(viewModel.$selectTabIndex, perform: { index in
                                viewModel.refresh(index, savedLocations)
                            })
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .id(savedLocations.count)

                            BottomSheetView(
                                isOpen: self.$bottomSheetShown,
                                maxHeight: geometry.size.height * 0.9
                            ) {
                                 ForecastView()
                            }
                             .edgesIgnoringSafeArea(.bottom)
                        }
                    }
                }
            }
            .environmentObject(viewModel)
        }
        //        .onReceive(refreshTimer){ _ in
        //            self.refresh(store.selectTabIndex)
        //        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if (viewModel.items.indices.contains(viewModel.selectTabIndex)) {
                viewModel.refresh(viewModel.selectTabIndex, savedLocations)
            }
        }
        .sheet(isPresented: $isSheetPresented, content: {
            SheetPane(locationSearchService: locationSearchService, savedLocations: savedLocations)
                .environmentObject(viewModel)
        })

    }
}
