//
//  PomodoroData.swift
//  Pomodoro
//
//  Created by Edward Kim on 5/27/23.
//

import Foundation

enum PomodoroStep {
    case pomodoro
    case shortBreak
    case longBreak
}

enum PomodoroState {
    case notStarted
    case inProgress
    case paused
}

struct PomodoroData {
    var currentStep: PomodoroStep
    var currentState: PomodoroState
    var timeRemaining: TimeInterval
    var timerInProgress: Bool
    var completedPomodoros: Int
    
    var pomodoroDuration: Double = 5
    var shortBreakDuration: Double = 5
    var longBreakDuration: Double = 5
    var numPomosForLongBreak: Int = 4
    
    func percentTimeRemaining() -> Double {
        guard currentState == .inProgress || currentState == .paused else {
            return 0.0
        }
        
        switch currentStep {
        case .pomodoro:
            return timeRemaining / pomodoroDuration
        case .shortBreak:
            return timeRemaining / shortBreakDuration
        case .longBreak:
            return timeRemaining / longBreakDuration
        }
    }
}
