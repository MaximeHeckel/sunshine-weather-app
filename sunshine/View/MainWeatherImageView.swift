//
// Created by Michael Rippe on 1/28/21.
//

import SwiftUI

struct MainWeatherImage: View {
    @State private var toggleAnimation = false
    var weather: WeatherObject
    var currentDayPart: MainDaypart

    var isMainAssetHigh: Bool {
        return currentDayPart == MainDaypart.mid || currentDayPart == MainDaypart.night
    }

    var body: some View {
        ZStack {
            if (weather.id >= 800) {
                MainAssetByDaypart(currentDayPart: currentDayPart)

                if (weather.id == 801 || weather.id == 802) {
                    Image("cloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 100)
                        .offset(x: toggleAnimation ? 40 : 300, y: isMainAssetHigh ? 20 : 100)
                        .animation(Animation.easeInOut(duration: toggleAnimation ? 3.0 : 0).delay(1))
                    Image("cloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 90)
                        .offset(x: toggleAnimation ? -20 : -300, y: isMainAssetHigh ? -10 : 70)
                        .animation(Animation.easeInOut(duration: toggleAnimation ? 3.0 : 0).delay(0.7))
                }

                if (weather.id > 802) {
                    // Broken clouds / overcast
                    Image("big-cloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 100)
                        .offset(x: toggleAnimation ? 0 : 300, y: isMainAssetHigh ? 20: 50)
                        .animation(Animation.easeInOut(duration: toggleAnimation ? 3.0 : 0))
                }
            }

            if (weather.id >= 500 && weather.id < 600) {
                if (weather.id <= 501) {
                    Image("light-rain-drops")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 50)

                } else {
                    Image("heavy-rain-drops")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 50)

                }
            }

            if (weather.id >= 300 && weather.id < 400) {
                if (weather.id <= 311) {
                    Image("light-rain-drops")
                        .resizable()

                } else {
                    Image("heavy-rain-drops")
                        .resizable()

                }
            }

            if (weather.id >= 200 && weather.id < 300) {
                // thunderstorm
                MainAssetByDaypart(currentDayPart: currentDayPart)
            }

            if (weather.id >= 600 && weather.id < 700) {
                // snow
                MainAssetByDaypart(currentDayPart: currentDayPart)
            }

            if (weather.id >= 700 && weather.id < 800) {
                // atmospheric
                MainAssetByDaypart(currentDayPart: currentDayPart)
            }

            else {
                // MainAssetByDaypart(currentDayPart: currentDayPart)
            }
        }
            .onAppear {
                ANIMATIONS_QUEUE.async {
                    toggleAnimation = true
                }
            }
    }
}