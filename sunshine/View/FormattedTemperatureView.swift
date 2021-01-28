//
// Created by Michael Rippe on 1/28/21.
//

import SwiftUI

struct FormattedTemperature: View {
    var temperature: Double
    var unit: Temperature

    var body: some View {
        switch(unit) {
        case Temperature.fahrenheit:
            Text(String(format: "%.0f°F", kelvinToFarenheit(temperature)))
        case Temperature.celsius:
            Text(String(format: "%.0f°C", kelvinToCelsius(temperature)))
        default:
            Text(String(format: "%.0f°K", temperature))
        }

    }
}