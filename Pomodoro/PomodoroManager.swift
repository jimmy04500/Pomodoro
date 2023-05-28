//
//  PomodoroManager.swift
//  Pomodoro
//
//  Created by Edward Kim on 5/27/23.
//

import Foundation

class PomodoroManager: ObservableObject {
    @Published var data: PomodoroData
    
    init() {
        data = PomodoroData(currentStep: .pomodoro, currentState: .notStarted, timeRemaining: 0, timerInProgress: false, completedPomodoros: 0)
    }
    
    func decrementTimeRemaining(delta: TimeInterval) {
        guard data.currentState == .inProgress else {
            fatalError("Invalid state \(data.currentStep) \(data.currentState)")
        }
        
        let resultTimeRemaining = data.timeRemaining - delta
        if resultTimeRemaining <= 0 {
            data.timeRemaining = 0
            data.timerInProgress = false
            data.currentState = .notStarted
            switch data.currentStep {
            case .pomodoro:
                data.completedPomodoros += 1
                if data.completedPomodoros == data.numPomosForLongBreak {
                    data.currentStep = .longBreak
                } else {
                    data.currentStep = .shortBreak
                }
            case .shortBreak:
                data.currentStep = .pomodoro
            case .longBreak:
                data.currentStep = .pomodoro
                data.completedPomodoros = 0
            }
        } else {
            data.timeRemaining = resultTimeRemaining
        }
    }
    
    func start(step: PomodoroStep) {
        guard data.currentState == .notStarted else {
            fatalError("Invalid state")
        }
        
        switch step {
        case .pomodoro:
            data.timeRemaining = data.pomodoroDuration
        case .shortBreak:
            data.timeRemaining = data.shortBreakDuration
        case .longBreak:
            data.timeRemaining = data.longBreakDuration
        }
        
        data.timerInProgress = true
        data.currentState = .inProgress
    }
    
    func pause(step: PomodoroStep) {
        guard data.currentState == .inProgress else {
            fatalError("Invalid state")
        }
        
        data.timerInProgress = false
        data.currentState = .paused
    }
    
    func resume(step: PomodoroStep) {
        guard data.currentState == .paused else {
            fatalError("Invalid state")
        }
        
        data.timerInProgress = true
        data.currentState = .inProgress
    }
    
    func stop() {
        data.timerInProgress = false
        data.currentStep = .pomodoro
        data.currentState = .notStarted
        data.completedPomodoros = 0
    }
}
