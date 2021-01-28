//
//  SunDial.swift
//  pagetest
//
//  Created by Maxime on 9/14/20.
//

import SwiftUI

struct Arc: Shape {
    var startAngle: Angle = .degrees(0)
    var endAngle: Angle = .degrees(180)
    var clockWise: Bool = true
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = CGFloat(130)
        
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockWise)

        return path
    }
}
//
//struct XAxis: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//
//        let center = CGPoint(x: rect.midX, y: rect.maxY)
//
//        path.move(to: center)
//        path.addLine(to: CGPoint(x: rect.minX, y: center.y))
//        path.addLine(to: CGPoint(x: rect.maxX, y: center.y))
//
//
//        return path
//    }
//}

struct SunDial: View {
    var sunrise: Int
    var sunset: Int
    var timestamp: Int
    var timezone: String
    
    let strokeDash: [CGFloat] = [5,5]

    @State private var targetAngle: Double = 0
    
    // let timer = Timer.publish(every: 600, on: .main, in: .common).autoconnect()
    var date: Date { Date(timeIntervalSince1970: Double(timestamp))}

    
    var nextAngle: Double {
        updateTargetAngle(date)
    }
    
    var body: some View {
        return
            ZStack {
                GeometryReader { geometry in
                    VStack(spacing: 15) {
                        Text("Sun from \(formatDateToHoursMinutes(sunrise)) to \(formatDateToHoursMinutes(sunset))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.top, 15)
                        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                            Arc()
                                .fill(LinearGradient(
                                            gradient: Gradient(stops: [
                                        .init(color: Color(#colorLiteral(red: 1, green: 0.892666757106781, blue: 0.6166666746139526, alpha: 1)), location: 0),
                                        .init(color: Color(#colorLiteral(red: 1, green: 0.6822500228881836, blue: 0.612500011920929, alpha: 0.30000001192092896)), location: 1)]),
                                            startPoint: UnitPoint(x: 0.5, y: 6.905165726926942e-15),
                                            endPoint: UnitPoint(x: 0.49999995240056083, y: 0.9718156807337223)))
//                                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 2, dash: strokeDash))
                           
                                .frame(height: 130)
                                .opacity(0.7)
//                            XAxis()
//                                .frame(width: 300, height: 5)
                            HStack(spacing: 245) {
                                VStack {
                                    Circle()
                                        .fill(Color.yellow)
                                        .frame(width: 10, height: 10)
                                }
                                VStack {
                                    Circle()
                                        .fill(Color.yellow)
                                        .frame(width: 10, height: 10)
                                    
                                }
                            }.padding(.bottom, 0)
                            VStack {
                                if (Int(date.timeIntervalSince1970) >= sunrise && Int(date.timeIntervalSince1970) < sunset) {
                                    Image("sun-mid")
                                        .resizable()
                                        .rotationEffect(.degrees(-self.targetAngle))
                                        .scaledToFit()
                                        .frame(height: 50)
                                        .position(x: 0, y: 0)
                                        .rotationEffect( .degrees(self.targetAngle))
                                        .animation(Animation.easeInOut(duration: 3 + 3 * self.targetAngle / 180))
                                }
                                
                            }
                            .frame(width: 260, height: 1)
                        }
                    }
                }
                .frame(height: 175)
                .clipped()
                .padding(.leading,10)
                .padding(.trailing,10)
                .animation(Animation.easeOut(duration: 0.7).delay(0))
                // On timer update
//                .onReceive(timer){time in
//                    self.targetAngle = updateTargetAngle(time)
//                }
                // On prop change
                .onChange(of: nextAngle) { angle in
                    self.targetAngle = angle
                }
                // On mount
                .onAppear {
                    // DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                      self.targetAngle = updateTargetAngle(date)
                    // }
                }
            }
    }
    
    func updateTargetAngle(_ updatedDate: Date) -> Double {
        return Double((Int(updatedDate.timeIntervalSince1970) - sunrise) * 180 / (sunset - sunrise))
    }
    
    func formatDateToHoursMinutes(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = NSLocale.current
        formatter.timeZone = TimeZone(identifier: timezone)
        var formattedDate:String {formatter.string(from: date)}
        
        return formattedDate
    }
    
    func str(hour: Int, minutes: Int) -> Double {
        return Double(hour) + Double(minutes) / 60
    }
}

struct SunDial_Previews: PreviewProvider {
    static var previews: some View {
        SunDial(sunrise: 1600374388, sunset: 1600418714, timestamp: 1600394388, timezone: "Asia/Tokyo")
    }
}

