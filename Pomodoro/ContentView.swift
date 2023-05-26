//
//  ContentView.swift
//  Pomodoro
//
//  Created by Edward Kim on 5/25/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var pomodoroViewModel: PomodoroViewModel
    
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
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(pomodoroViewModel: PomodoroViewModel())
    }
}
