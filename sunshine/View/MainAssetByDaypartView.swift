//
// Created by Michael Rippe on 1/28/21.
//

import SwiftUI

struct MainAssetByDaypart: View {
    @State private var toggleAnimation = false
    var currentDayPart: MainDaypart

    var body: some View {
        if (currentDayPart == MainDaypart.night) {
            Image(systemName: "moon") // temporarily silence missing asset error
                .resizable()
                .frame(width: 140.0, height: 140.0)
                .opacity(toggleAnimation ? 1: 0)
                .animation(Animation.easeInOut(duration: 2.0).delay(0.7))
                .onAppear {
                    ANIMATIONS_QUEUE.async {
                        self.toggleAnimation = true
                    }
                }
        }

        if (currentDayPart == MainDaypart.mid) {
            Image("sun-mid").resizable()
                .frame(width: 200.0, height: 200.0)
                .offset(y: toggleAnimation ?  0 : 100)
                .animation(Animation.easeInOut(duration: 2.0).delay(0.7))
                .onAppear {
                    ANIMATIONS_QUEUE.async {
                        self.toggleAnimation = true
                    }
                }
        }

        if(currentDayPart == MainDaypart.dusk) {
            Image("sun-dawn").resizable()
                .frame(width: 200.0, height: 200.0)
                .opacity(toggleAnimation ?  1 : 0)
                .offset(y: toggleAnimation ?  100 : 0)
                .animation(Animation.easeInOut(duration: 2.0).delay(0.5).delay(0.7))
                .onAppear {
                    ANIMATIONS_QUEUE.async {
                        self.toggleAnimation = true
                    }
                }
        }

        if(currentDayPart == MainDaypart.dawn) {
            Image("sun-dawn").resizable()
                .frame(width: 200.0, height: 200.0)
                .offset(y: toggleAnimation ?  100 : 180)
                .animation(Animation.easeInOut(duration: 2.0).delay(0.7))
                .onAppear {
                    ANIMATIONS_QUEUE.async {
                        self.toggleAnimation = true
                    }
                }
        }
    }
}