//
//  ContentView.swift
//  Pomodoro
//
//  Created by Edward Kim on 5/25/23.
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
        } else {
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
    var shouldAnimate: Bool
    var animationDuration: Double
    
    var body: some View {
        VisualCountdownTimerShape(percentFilled: percentFilled)
            .fill(backgroundColor)
            .animation(shouldAnimate ? .linear(duration: animationDuration) : nil, value: percentFilled)
    }
}


struct ContentView: View {
    @StateObject var pomodoroViewModel: PomodoroViewModel
    
    @State private var percentFilled: Double = 1.0
    @State private var shouldAnimate: Bool = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if pomodoroViewModel.currentStep == .PomodoroNotStarted {
                Text("Start Pomodoro \(pomodoroViewModel.completedPomodoros+1)/4")
                Button(action: pomodoroViewModel.startPomodoro) {
                    Text("Start")
                }
            } else if pomodoroViewModel.currentStep == .PomodoroInProgress {
                Text("Work Hard! \(pomodoroViewModel.displayTimeRemaining)")
            } else if pomodoroViewModel.currentStep == .ShortBreakNotStarted {
                Text("Start Short Break")
                Button(action: pomodoroViewModel.startShortBreak) {
                    Text("Start")
                }
            } else if pomodoroViewModel.currentStep == .ShortBreakInProgress {
                Text("Short Break \(pomodoroViewModel.displayTimeRemaining)")
            } else if pomodoroViewModel.currentStep == .LongBreakNotStarted {
                Text("Start Long Break")
                Button(action: pomodoroViewModel.startLongBreak) {
                    Text("Start")
                }
            } else if pomodoroViewModel.currentStep == .LongBreakInProgress {
                Text("Long Break \(pomodoroViewModel.displayTimeRemaining)")
            }
            VisualCountdownTimerView(percentFilled: pomodoroViewModel.percentTimeRemaining, backgroundColor: Color.red, shouldAnimate: true, animationDuration: 1)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(pomodoroViewModel: PomodoroViewModel())
    }
}
