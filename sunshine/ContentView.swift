//
//  ContentView.swift
//  sunshine
//
//  Created by Maxime on 8/22/20.
//

import SwiftUI
import CoreData

let gradients: [MainDaypart: [Color]]! = [
    MainDaypart.dawn: [Color("Pink Dawn"), Color("Blue Dawn End Gradient")],
    MainDaypart.mid: [Color("Blue Mid Day"), Color("Blue Mid Day End Gradient")],
    MainDaypart.dusk: [Color("Blue Dusk"), Color("Peach Dusk End Gradient")],
    MainDaypart.night: [Color("Blue Night"),  Color("Blue Night End Gradient")]]

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

func kelvinToFarenheit(_ kelvin: Double) -> Double {
    return kelvin * 1.8 - 459.67
}

func kelvinToCelsius(_ celsius: Double) -> Double {
    return celsius - 273.15
}

func metersPerSecToMPH(_ mps: Double) -> Double {
    return mps / 0.44704
}

func metersPerSecToKMH(_ mps: Double) -> Double {
    return mps * 18 / 5
}

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

let REFRESH_INTERVAL = 1800



struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct BottomSheetView<Content: View>: View {
    @Binding var isOpen: Bool
    @GestureState private var translation: CGFloat = 0

    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content

    init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.minHeight = maxHeight * 1/7
        self.maxHeight = maxHeight
        self.content = content()
        self._isOpen = isOpen
    }

    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }

    private var indicator: some View {
        RoundedRectangle(cornerRadius: 50)
            .fill(Color.secondary)
            .frame(
                width: 100,
                height: 5
            )
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                self.indicator.padding()
                self.content
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(25)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.interactiveSpring())
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = self.maxHeight * 0.2
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    self.isOpen = value.translation.height < 0
                }
            )
        }
    }
}

struct MetricsRow: View {
    var forecast: Response
    var speedUnit: Speed

    @State private var toggleAnimation = false

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                HStack {
                    Image("humidity")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14)
                    Text("\(forecast.current.humidity)%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black)
                }
                HStack {
                    Image(systemName: "wind")
                        .foregroundColor(.black)
                    FormattedSpeed(speed: forecast.current.windSpeed, unit: speedUnit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black)
                }
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(Double(45 - forecast.current.windDeg)))
                        .animation(.spring())
                    Text("\(forecast.current.windDeg)°")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black)
                }
                HStack {
                    Image(systemName: "cloud")
                        .foregroundColor(.black)
                    Text("\(forecast.current.clouds)%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .padding(.top, 10)
        }
        .frame(height: 35)
        .onAppear {
             self.toggleAnimation = true
        }
    }
}

struct MainAssetByDaypart: View {
    @State private var toggleAnimation = false
    var currentDayPart: MainDaypart

    var body: some View {
        if (currentDayPart == MainDaypart.night) {
            Image("moon")
                .resizable()
                .frame(width: 140.0, height: 140.0)
                .opacity(toggleAnimation ? 1: 0)
                .animation(Animation.easeInOut(duration: 2.0).delay(0.7))
                .onAppear {
                    self.toggleAnimation = true
                }
        }

        if (currentDayPart == MainDaypart.mid) {
            Image("sun-mid").resizable()
                .frame(width: 200.0, height: 200.0)
                .offset(y: toggleAnimation ?  0 : 100)
                .animation(Animation.easeInOut(duration: 2.0).delay(0.7))
                .onAppear {
                    self.toggleAnimation = true
                }
        }

        if(currentDayPart == MainDaypart.dusk) {
            Image("sun-dawn").resizable()
                .frame(width: 200.0, height: 200.0)
                .opacity(toggleAnimation ?  1 : 0)
                .offset(y: toggleAnimation ?  100 : 0)
                .animation(Animation.easeInOut(duration: 2.0).delay(0.5).delay(0.7))
                .onAppear {
                    self.toggleAnimation = true
                }
        }

        if(currentDayPart == MainDaypart.dawn) {
            Image("sun-dawn").resizable()
                .frame(width: 200.0, height: 200.0)
                .offset(y: toggleAnimation ?  100 : 180)
                .animation(Animation.easeInOut(duration: 2.0).delay(0.7))
                .onAppear {
                    self.toggleAnimation = true
                }
        }
    }
}

func isCloudy(_ weatherId: Int) -> Bool {
    if (weatherId > 802 || weatherId >= 500 && weatherId < 600 || weatherId >= 200 && weatherId < 300 || weatherId >= 600 && weatherId < 700) {
        return true
    }

    return false
}

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
            self.toggleAnimation = true
        }
    }
}

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

            if (diff >= REFRESH_INTERVAL) {
                // print("Refresh")
                fetch(index, savedLocations)
            }
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
