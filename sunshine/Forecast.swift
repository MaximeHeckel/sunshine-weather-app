//
//  Forecast.swift
//  sunshine
//
//  Created by Maxime on 11/25/20.
//

import SwiftUI

struct WeatherImage: View {
    var weather: WeatherObject
    var daypart: MainDaypart
    
    var body: some View {
        ZStack {
            if(weather.id == 800) {
                if (daypart == MainDaypart.night) {
                    Image("moon")
                        .resizable()
                        .scaledToFit()
                }
                
                if (daypart == MainDaypart.mid) {
                    Image("sun-mid")
                        .resizable()
                        .scaledToFit()
                }
                
                if(daypart == MainDaypart.dawn || daypart == MainDaypart.dusk) {
                    Image("sun-dawn")
                        .resizable()
                        .scaledToFit()
                }
            }
            
            if (weather.id == 801 || weather.id == 802) {
                Image("clouds")
                    .resizable()
                    .scaledToFit()
            }
            
            if (weather.id > 802) {
                Image("big-cloud")
                    .resizable()
                    .scaledToFit()
            }
            
            if (weather.id >= 500 && weather.id < 600) {
                if (weather.id <= 501) {
                    Image("light-rain-drops")
                        .resizable()
                        .scaledToFit()
                } else {
                    Image("heavy-rain-drops")
                        .resizable()
                        .scaledToFit()
                }
            }
            
            if (weather.id >= 300 && weather.id < 400) {
                if (weather.id <= 311) {
                    Image("light-rain-drops")
                        .resizable()
                        .scaledToFit()
                } else {
                    Image("heavy-rain-drops")
                        .resizable()
                        .scaledToFit()
                }
            }
        }
    }
}

struct HourlyCard: View {
    var forecast: HourlyForecast
    var timezone: String
    var sunrise: Int
    var sunset: Int
    var nextDaySunrise: Int
    var tempUnit: Temperature

    
    var currentDayPart: MainDaypart {
        return getDayPart(sunrise: Double(sunrise), sunset: Double(sunset), nextDaySunrise: Double(nextDaySunrise), timestamp: Double(forecast.dt))
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(
                        gradient: Gradient(colors: gradients[currentDayPart]!),
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.5, y: 0.6)))
                .frame(width: 60, height: 120)
                .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25)), radius:5, x:0, y:4)
            if (isCloudy(forecast.weather[0].id)) {
                if (currentDayPart == MainDaypart.night) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(LinearGradient(
                                gradient: Gradient(stops: [
                                                    .init(color: Color(#colorLiteral(red: 0.09019608050584793, green: 0.1411764770746231, blue: 0.16862745583057404, alpha: 1)), location: 0),
                                                    .init(color: Color(#colorLiteral(red: 0.250980406999588, green: 0.2705882489681244, blue: 0.3294117748737335, alpha: 1)), location: 1)]),
                                startPoint: UnitPoint(x: 0, y: 0.5),
                                endPoint: UnitPoint(x: 1.2, y: 0.5)))
                        .opacity(0.7)
                        .frame(width: 60, height: 120)
                } else {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(LinearGradient(
                                gradient: Gradient(stops: [
                                                    .init(color: Color(#colorLiteral(red: 0.6976562142, green: 0.7035937309, blue: 0.7124999762, alpha: 0.700952492)), location: 0),
                                                    .init(color: Color(#colorLiteral(red: 0.8545138835906982, green: 0.8718518614768982, blue: 0.8916666507720947, alpha: 0.20000000298023224)), location: 1)]),
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 0.5)))
                        .opacity(0.7)
                        .frame(width: 60, height: 120)
                }
            }
            VStack {
                FormattedTemperature(temperature: forecast.temp, unit: tempUnit)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                WeatherImage(weather: forecast.weather[0], daypart: currentDayPart)
                    .frame(width: 50, height: 50)
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .light))
                    Text("\(formatToLocalTime(forecast.dt, timezone))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.black)
                }
                .frame(height: 25, alignment: .bottom)
            }
            .cornerRadius(15)
            .frame(height: 120)
            .clipped()
        }
        .frame(height: 140)
    }
    
    func formatToLocalTime(_ timestamp: Int, _ timezone: String) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = NSLocale.current
        formatter.timeZone = TimeZone(identifier: timezone)
        var formattedDate:String {formatter.string(from: date)}
        
        return formattedDate
    }
}

struct NextSixHours: View {
    var hourly: [HourlyForecast]
    var timezone: String
    var sunrise: Int
    var sunset: Int
    var nextDaySunrise: Int
    var tempUnit: Temperature
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(hourly.prefix(6), id: \.dt) { forecast in
                    HourlyCard(forecast: forecast, timezone:timezone, sunrise: sunrise, sunset: sunset, nextDaySunrise: nextDaySunrise, tempUnit: tempUnit)
                        .padding(.leading, 10)
                }
            }
       }
    }
}

struct DailyCard: View {
    var forecast: DailyForecast
    var tempUnit: Temperature
    
    let height: CGFloat = 70
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                        gradient: Gradient(colors: gradients[MainDaypart.mid]!),
                        startPoint: UnitPoint(x: 0, y: 0.5),
                        endPoint: UnitPoint(x: 1.2, y: 0.5)))
                .frame(height: height)
                .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25)), radius:5, x:0, y:4)
            if (isCloudy(forecast.weather[0].id)) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                            gradient: Gradient(stops: [
                                                .init(color: Color(#colorLiteral(red: 0.6976562142, green: 0.7035937309, blue: 0.7124999762, alpha: 0.700952492)), location: 0),
                                                .init(color: Color(#colorLiteral(red: 0.8545138835906982, green: 0.8718518614768982, blue: 0.8916666507720947, alpha: 0.20000000298023224)), location: 1)]),
                            startPoint: UnitPoint(x: 0, y: 0.5),
                            endPoint: UnitPoint(x: 1.2, y: 0.5)))
                    .opacity(0.7)
                    .frame(height: height)
            }
            HStack {
                Text(Date(timeIntervalSince1970: Double(forecast.dt)), formatter: formatter)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                HStack(alignment: .bottom) {
                    FormattedTemperature(temperature: forecast.temp.max, unit: tempUnit)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    FormattedTemperature(temperature: forecast.temp.min, unit: tempUnit)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                HStack {
                    Text("\(forecast.weather[0].main.rawValue)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    WeatherImage(weather: forecast.weather[0], daypart: MainDaypart.mid)
                        .frame(width: 50, height: 50)
                }.frame(width: 150, alignment: .trailing)
                
            }
            .padding([.leading, .trailing], 10)
        }
    }
}

struct NextSevenDays: View {
    var daily: [DailyForecast]
    var tempUnit: Temperature
    
    var body: some View {
        VStack {
            ForEach(daily.suffix(7), id: \.dt) { forecast in
                DailyCard(forecast: forecast, tempUnit: tempUnit)
                    .padding([.leading, .trailing], 10)
                    .padding([.bottom], 5)
            }
        }
    }
}

struct ForecastView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Forecast").font(.system(size: 24, weight: .medium))
                Spacer()
            }
            .padding([.leading, .trailing], 20)
            .padding(.top, 5)
            .padding(.bottom, 10)
            
            if(viewModel.state == ViewState.loading) {
                Text("loading")
            }
            
            if(viewModel.state == ViewState.idle && viewModel.focusedItem != nil){
                ScrollView {
                    VStack {
                        HStack {
                            Text("Next 6 Hours").font(.system(size: 18, weight: .medium))
                            Spacer()
                        }
                        .padding([.leading, .trailing], 20)
                        NextSixHours(hourly: viewModel.focusedItem!.hourly, timezone: viewModel.focusedItem!.timezone, sunrise: viewModel.focusedItem!.current.sunrise, sunset: viewModel.focusedItem!.current.sunset, nextDaySunrise: viewModel.focusedItem!.daily[1].sunrise, tempUnit: viewModel.temperature)
                        HStack {
                            Text("Next 7 Days").font(.system(size: 18, weight: .medium))
                            Spacer()
                        }
                        .padding([.top, .leading, .trailing], 20)
                        NextSevenDays(daily: viewModel.focusedItem!.daily, tempUnit: viewModel.temperature)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}

