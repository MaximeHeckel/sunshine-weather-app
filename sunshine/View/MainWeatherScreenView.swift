//
// Created by Michael Rippe on 1/28/21.
//

import SwiftUI

struct MainWeatherScreen: View {
    var forecast: Response!
    var isSelected: Bool
    var name: String
    var status: ViewState
    var tempUnit: Temperature
    var speedUnit: Speed

    var currentDayPart: MainDaypart {
        return getDayPart(sunrise: Double(forecast.current.sunrise), sunset: Double(forecast.current.sunset), nextDaySunrise: Double(forecast.daily[1].sunrise), timestamp: Double(forecast.current.dt))
    }


    var body: some View {
        VStack(spacing: 0) {
            if (status == ViewState.loading && forecast == nil) {
                VStack(alignment: .leading) {
                    Text(" ").font(.system(size: 16, weight: .medium, design: Font.Design.default)).foregroundColor(Color(#colorLiteral(red: 0.5920000076293945, green: 0.5920000076293945, blue: 0.5920000076293945, alpha: 1)))
                    HStack {
                        Text("\(name)").font(.system(size: 24, weight: .medium))
                        Spacer()
                    }
                }
                    .padding([.leading, .trailing], 20)
                    .frame(height: 105, alignment: .leading)
                Spacer()
            }
            if (status == ViewState.error) {
                Text("Error :(")
            }
            if (status != ViewState.error && forecast != nil) {
                VStack(alignment: .leading) {
                    Text("\(getDate(forecast.current.dt))").font(.system(size: 16, weight: .bold, design: Font.Design.default)).foregroundColor(Color(#colorLiteral(red: 0.5920000076293945, green: 0.5920000076293945, blue: 0.5920000076293945, alpha: 1)))
                    HStack {
                        Text("\(name)").font(.system(size: 24, weight: .medium))
                        Spacer()
                    }

                }
                    .padding([.leading, .trailing], 20)
                    .frame(height: 105, alignment: .leading)

                // Main Card
                VStack {
                    if (isSelected) {
                        MainCard(forecast: forecast, currentDayPart: currentDayPart, tempUnit: tempUnit, speedUnit: speedUnit)
                        if(currentDayPart == MainDaypart.night){
                            if (forecast.current.dt > forecast.current.sunset) {
                                DailyCard(forecast: forecast.daily[1], tempUnit: tempUnit)
                                    .padding([.leading, .trailing], 10)
                                    .padding([.top], 10)
                            } else {
                                DailyCard(forecast: forecast.daily[0], tempUnit: tempUnit)
                                    .padding([.leading, .trailing], 10)
                                    .padding([.top], 10)
                            }
                        }
                        Spacer()
                    } else {
                        Spacer()
                    }
                }
                    .transition(.opacity)
                    .animation(.easeInOut)
            }

        }
            .transition(.opacity)
            .animation(.easeInOut)
    }

    func getDate(_ timestamp: Int) -> String {
        var date: Date { Date(timeIntervalSince1970: Double(timestamp)) }
        let formatter = DateFormatter()
        formatter.dateFormat = "E MMM dd"
        formatter.timeZone = TimeZone(identifier: forecast.timezone)
        var formattedDate:String {formatter.string(from: date)}

        return formattedDate
    }
}