//
// Created by Michael Rippe on 1/28/21.
//

import SwiftUI
import Combine

class ViewModel: ObservableObject {
    @Published var state: ViewState
    @Published var items: [Response] {
        didSet {
            self.focusedItem = items.indices.contains(selectTabIndex) ? items[selectTabIndex] : nil
        }
    }
    @Published var selectTabIndex: Int {
        didSet {
            self.focusedItem = items.indices.contains(selectTabIndex) ? items[selectTabIndex] : nil
        }
    }
    @Published var temperature: Temperature {
        didSet {
            UserDefaults.standard.set(temperature.rawValue, forKey: "temperature")
        }
    }
    @Published var speed: Speed {
        didSet {
            UserDefaults.standard.set(speed.rawValue, forKey: "speed")
        }
    }

    @Published var focusedItem: Response?


    let client = WeatherAPIClient()

    init() {
        self.focusedItem = nil
        self.selectTabIndex = 0
        self.state = ViewState.idle
        self.items = [Response]()
        self.temperature = (UserDefaults.standard.object(forKey: "temperature") == nil ? Temperature.fahrenheit : Temperature(rawValue: UserDefaults.standard.object(forKey: "temperature") as! Int)) ?? Temperature.fahrenheit
        self.speed = (UserDefaults.standard.object(forKey: "speed") == nil ? Speed.mph : Speed(rawValue: UserDefaults.standard.object(forKey: "speed") as! Int)) ?? Speed.mph
    }



    func refresh(_ index: Int, _ savedLocations: FetchedResults<Location>) {
        // print("Trying refresh at index \(index)")
        if (!items.indices.contains(index) && savedLocations.indices.contains(index)) {
            fetch(index, savedLocations)
            return
        } else if (savedLocations.indices.contains(index)) {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, dd MMM, HH:mm:ss"
            var formattedDate:String {formatter.string(from: Date(timeIntervalSince1970: Double(items[index].current.dt)))}

            let diff = Int(Date().timeIntervalSince1970) - items[index].current.dt

            //if (diff >= REFRESH_INTERVAL) {
                // print("Refresh")
                //fetch(index, savedLocations)
            //}
        }
        return
    }

    private func fetch(_ index: Int, _ savedLocations: FetchedResults<Location>) {
        if (savedLocations.indices.contains(index)) {
            self.state = ViewState.loading
            client.fetch(lat: savedLocations[index].lat, lon: savedLocations[index].lon) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        DispatchQueue.main.async {
                            if (!self.items.indices.contains(index)) {
                                self.items.append(response)
                            } else {
                                self.items[index] = response
                            }
                            self.state = ViewState.idle

                        }

                    case .failure(let error):
                        print("Error! \(error)")
                        self.state = ViewState.error
                    }

                }
            }
        }
    }
}