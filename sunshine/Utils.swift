//
// Created by Michael Rippe on 1/28/21.
//

import Foundation

func isCloudy(_ weatherId: Int) -> Bool {
    if (weatherId > 802 || weatherId >= 500 && weatherId < 600 || weatherId >= 200 && weatherId < 300 || weatherId >= 600 && weatherId < 700) {
        return true
    }

    return false
}

func kelvinToFarenheit(_ kelvin: Double) -> Double {
    kelvin * 1.8 - 459.67
}

func kelvinToCelsius(_ celsius: Double) -> Double {
    celsius - 273.15
}

func metersPerSecToMPH(_ mps: Double) -> Double {
    mps / 0.44704
}

func metersPerSecToKMH(_ mps: Double) -> Double {
    mps * 18 / 5
}

func getDayPart(sunrise: Double, sunset: Double, nextDaySunrise: Double, timestamp: Double) -> MainDaypart {
    let dawnStart = sunrise - 86400 * 0.03
    let dawnEnd = sunrise + 86400 * 0.05
    let duskStart = sunset - 86400 * 0.03
    let duskEnd = sunset + 86400 * 0.05

    let nextDawnStart = nextDaySunrise - 86400 * 0.03
    let nextDawnEnd = nextDaySunrise + 86400 * 0.05

    if (timestamp > sunset && timestamp > dawnStart && timestamp < nextDawnStart) {
        // Current day after sunset before next sunset (sunrise is day 1 sunrise thus < timestramp)
        return MainDaypart.night
    }

    if (timestamp < duskEnd && timestamp < dawnStart) {
        // Next day, timestamp is both < sunrise and < sunset
        return MainDaypart.night
    }

    if (timestamp > dawnStart && timestamp < dawnEnd) {
        // Current day sunrise
        return MainDaypart.dawn
    }

    if (timestamp > nextDawnStart && timestamp < nextDawnEnd) {
        // Next day sunrise (for hourly forecast)
        return MainDaypart.dawn
    }

    if (timestamp > duskStart && timestamp < duskEnd) {
        return MainDaypart.dusk
    }

    return MainDaypart.mid
}