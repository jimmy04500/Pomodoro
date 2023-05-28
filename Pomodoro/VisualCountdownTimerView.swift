//
//  VisualCountdownTimerView.swift
//  Pomodoro
//
//  Created by Edward Kim on 5/27/23.
//

import SwiftUI

struct VisualCountdownTimerShape: Shape {
    var percentFilled: Double
    
    var animatableData: Double {
       get { percentFilled }
       set { percentFilled = newValue }
   }
    
    func path(in rect: CGRect) -> Path {
        let startAngle = Angle(degrees: -90)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        var path = Path()

        if percentFilled >= 1.0 {
            path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius))
        } else if percentFilled > 0 {
            let start = CGPoint(
                x: center.x + radius * cos(CGFloat(startAngle.radians)),
                y: center.y + radius * sin(CGFloat(startAngle.radians))
            )

            let endAngle = Angle(degrees: 360 * (1 - percentFilled) - 90)

            path.move(to: center)
            path.addLine(to: start)
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.addLine(to: center)
        }

        return path
    }
}

struct VisualCountdownTimerView: View {
    var percentFilled: Double
    var backgroundColor: Color
    var animation: Animation
    
    var body: some View {
        VisualCountdownTimerShape(percentFilled: percentFilled)
            .fill(backgroundColor)
            .animation(animation, value: percentFilled)
            .animation(.linear, value: backgroundColor)
    }
}

//struct VisualCountdownTimerView_Previews: PreviewProvider {
//    static var previews: some View {
//        VisualCountdownTimerView()
//    }
//}
