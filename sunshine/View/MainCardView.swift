//
// Created by Michael Rippe on 1/28/21.
//

import SwiftUI

struct MainCard: View {

    var forecast: Response
    var currentDayPart: MainDaypart
    var tempUnit: Temperature
    var speedUnit: Speed

    var gradient: [Color] {
        return gradients[currentDayPart] ?? [Color.white]
    }

    var body: some View {
        VStack {
            ZStack {
                // Main Card with background and little drop shaddow based on time of day (daypart)
                RoundedRectangle(cornerRadius: 25)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: gradient),
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.5, y: 0.6)))
                    .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25)), radius:10, x:0, y:4)

                // Cloudy overlay
                if (isCloudy(forecast.current.weather[0].id)) {
                    if (currentDayPart == MainDaypart.night) {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(#colorLiteral(red: 0.09019608050584793, green: 0.1411764770746231, blue: 0.16862745583057404, alpha: 1)), location: 0),
                                    .init(color: Color(#colorLiteral(red: 0.250980406999588, green: 0.2705882489681244, blue: 0.3294117748737335, alpha: 1)), location: 1)]),
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 0.5)))
                            .opacity(0.7)
                    } else {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(#colorLiteral(red: 0.6976562142, green: 0.7035937309, blue: 0.7124999762, alpha: 0.700952492)), location: 0),
                                    .init(color: Color(#colorLiteral(red: 0.8545138835906982, green: 0.8718518614768982, blue: 0.8916666507720947, alpha: 0.20000000298023224)), location: 1)]),
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 0.5)))
                            .opacity(0.7)
                    }
                }

                // Assets based on weather and time (each asset may have it's own position)
                GeometryReader { geometry in
                    MainWeatherImage(weather: forecast.current.weather[0], currentDayPart: currentDayPart)
                        .frame(width: geometry.size.width, height: 260)
                        .clipped()
                }

                // Temperature, conditions, feels like
                VStack {
                    HStack {
                        FormattedTemperature(temperature: forecast.current.temp, unit: tempUnit).font(.system(size: 36, weight: .medium)).foregroundColor(.white)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(forecast.current.weather[0].description.capitalized)").font(.system(size: 24, weight: .medium)).foregroundColor(.white)
                            HStack(spacing: 3) {
                                Text("Feels like")
                                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                FormattedTemperature(temperature: forecast.current.feelsLike, unit: tempUnit)
                                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                            }
                        }

                    }.padding(15)

                    Spacer()

                    ZStack {
                        VisualEffectView(effect: UIBlurEffect(style: .light))
                            .cornerRadius(25)
                        VStack {
                            MetricsRow(forecast: forecast, speedUnit: speedUnit)
                            Rectangle()
                                .fill(Color.black)
                                .frame(height: 1)
                                .opacity(0.05)
                            if (currentDayPart != MainDaypart.night) {
                                SunDial(sunrise: forecast.current.sunrise, sunset: forecast.current.sunset, timestamp: forecast.current.dt, timezone: forecast.timezone)
                            } else {
                                VStack {
                                    Text("Next sunrise at \(getNextSunriseTime(forecast.current.sunrise))")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black)

                                }
                                    .frame(height: 70)
                                    .padding(.leading,5)
                                    .padding(.trailing,5)
                            }
                        }

                    }
                        .frame(height:currentDayPart == MainDaypart.night ? 125 : 230)
                }
            }
        }
            .frame(height: currentDayPart == MainDaypart.night ? 385 : 475)
            .padding(.leading,8)
            .padding(.trailing,8)
    }


    func getNextSunriseTime(_ sunrise: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(sunrise))
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = NSLocale.current
        formatter.timeZone = TimeZone(identifier: forecast.timezone)
        var formattedDate:String {formatter.string(from: date)}

        return formattedDate
    }
}