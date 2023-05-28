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

        if percentFilled >= 1.0 || percentFilled < 0 {
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
    
    var body: some View {
        VisualCountdownTimerShape(percentFilled: percentFilled)
            .fill(backgroundColor)
            .animation(.linear, value: backgroundColor)
    }
}


struct ContentView: View {
    @StateObject var pomodoroViewModel: PomodoroViewModel
    @State private var showAlert = false
    
    var backgroundColor: Color {
        switch pomodoroViewModel.currentStep {
        case .pomodoro:
            return .red
        case .shortBreak:
            return .green
        case .longBreak:
            return .blue
        }
    }
    
    var body: some View {
        VStack {
            if pomodoroViewModel.currentStep == .pomodoro {
                if pomodoroViewModel.currentState == .notStarted {
                    HStack {
                        Text("Start Pomodoro \(pomodoroViewModel.completedPomodoros+1)/4")
                        Button(action: {
                            pomodoroViewModel.start(pomodoroStep: .pomodoro)
                        }) {
                            Text("Start")
                        }
                    }
                } else if pomodoroViewModel.currentState == .inProgress {
                    HStack {
                        Text("Work Hard! \(pomodoroViewModel.displayTimeRemaining)")
                        Button(action: {
                            pomodoroViewModel.pause(pomodoroStep: .pomodoro)
                        }) {
                            Text("Pause")
                        }
                        Button(action: {
                            showAlert = true
                        }) {
                            Text("Stop")
                        }
                    }
                } else if pomodoroViewModel.currentState == .paused {
                    HStack {
                        Text("Pomodoro Paused")
                        Button(action: {
                            pomodoroViewModel.resume(pomodoroStep: .pomodoro)
                        }) {
                            Text("Resume")
                        }
                    }
                }
            } else if pomodoroViewModel.currentStep == .shortBreak {
                if pomodoroViewModel.currentState == .notStarted {
                    HStack {
                        Text("Start Short Break")
                        Button(action: {
                            pomodoroViewModel.start(pomodoroStep: .shortBreak)
                        }) {
                            Text("Start")
                        }
                    }
                } else if pomodoroViewModel.currentState == .inProgress {
                    HStack {
                        Text("Short Break \(pomodoroViewModel.displayTimeRemaining)")
                        Button(action: {
                            
                        }) {
                            Text("Pause")
                        }
                        Button(action: {
                            showAlert = true
                        }) {
                            Text("Stop")
                        }
                    }
                } else if pomodoroViewModel.currentState == .paused {
                    HStack {
                        Text("Short Break Paused")
                        Button(action: {
                            pomodoroViewModel.resume(pomodoroStep: .shortBreak)
                        }) {
                            Text("Resume")
                        }
                    }
                }
            } else if pomodoroViewModel.currentStep == .longBreak {
                if pomodoroViewModel.currentState == .notStarted {
                    HStack {
                        Text("Start Long Break")
                        Button(action: {
                            pomodoroViewModel.start(pomodoroStep: .longBreak)
                        }) {
                            Text("Start")
                        }
                    }
                } else if pomodoroViewModel.currentState == .inProgress {
                    HStack {
                        Text("Short Break \(pomodoroViewModel.displayTimeRemaining)")
                        Button(action: {
                            
                        }) {
                            Text("Pause")
                        }
                        Button(action: {
                            showAlert = true
                        }) {
                            Text("Stop")
                        }
                    }
                } else if pomodoroViewModel.currentState == .paused {
                    HStack {
                        Text("Long Break Paused")
                        Button(action: {
                            pomodoroViewModel.resume(pomodoroStep: .longBreak)
                        }) {
                            Text("Resume")
                        }
                    }
                }
            }
            VisualCountdownTimerView(percentFilled: pomodoroViewModel.percentTimeRemaining, backgroundColor: backgroundColor)
        }
        .confirmationDialog("Stop Pomodoro", isPresented: $showAlert) {
            Button("Stop Pomodoro", role: .destructive) {
                pomodoroViewModel.stop()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(pomodoroViewModel: PomodoroViewModel())
    }
}
