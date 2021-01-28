//
// Created by Michael Rippe on 1/28/21.
//

import SwiftUI

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