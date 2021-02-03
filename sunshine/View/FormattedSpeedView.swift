//
// Created by Michael Rippe on 1/28/21.
//

import SwiftUI

struct FormattedSpeed: View {
    var speed: Double
    var unit: Speed

    var body: some View {
        switch(unit) {
        case Speed.mph:
            Text(String(format: "%.1f mph", metersPerSecToMPH(speed)))
        case Speed.kmh:
            Text(String(format: "%.1f km/h", metersPerSecToKMH(speed)))
        default:
            Text(String(format: "%.1f m/s", speed))

        }
    }
}