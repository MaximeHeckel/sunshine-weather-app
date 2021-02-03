//
// Created by Michael Rippe on 1/28/21.
//

import SwiftUI

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