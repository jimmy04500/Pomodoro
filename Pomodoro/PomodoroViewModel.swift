//
//  TimerData.swift
//  Pomodoro
//
//  Created by Edward Kim on 5/25/23.
//

import Foundation
import Combine

enum PomodoroType {
    case PomodoroNotStarted
    case PomodoroInProgress
    case PomodoroPaused
    case ShortBreakNotStarted
    case ShortBreakInProgress
    case ShortBreakPaused
    case LongBreakNotStarted
    case LongBreakInProgress
    case LongBreakPaused
}

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
//    var currentStep: PomodoroType
    
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
        guard currentState == .inProgress else {
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

class PomodoroManager: ObservableObject {
    @Published var data: PomodoroData
    
    init() {
        data = PomodoroData(currentStep: .pomodoro, currentState: .notStarted, timeRemaining: 0, timerInProgress: false, completedPomodoros: 0)
    }
    
    func decrementTimeRemaining(delta: TimeInterval) {
        guard data.currentState == .inProgress else {
            fatalError("Invalid state \(data.currentStep)")
        }
        
        let resultTimeRemaining = data.timeRemaining - delta
        if resultTimeRemaining <= 0 {
            data.timerInProgress = false
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
            data.currentState = .notStarted
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
}

class PomodoroViewModel: ObservableObject {
    private let manager = PomodoroManager()
    private var timer: Timer? = nil
    
    @Published var displayTimeRemaining = "00:00"
    @Published var percentTimeRemaining = 1.0
    @Published var currentStep = PomodoroStep.pomodoro
    @Published var currentState = PomodoroState.notStarted
    @Published var completedPomodoros = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        manager.$data
            .removeDuplicates { before, after in
                before.timeRemaining == after.timeRemaining
            }
            .map { data in
                data.timeRemaining
            }
            .sink { timeRemaining in
                let minutes = Int(timeRemaining / 60)
                let seconds = Int(timeRemaining.truncatingRemainder(dividingBy: 60))
                self.displayTimeRemaining = String(format: "%02d:%02d", minutes, seconds)
            }
            .store(in: &cancellables)
        
        manager.$data
            .removeDuplicates { before, after in
                before.currentStep == after.currentStep
            }
            .map { data in
                data.currentStep
            }
            .sink { currentStep in
                self.currentStep = currentStep
            }
            .store(in: &cancellables)
        
        manager.$data
            .removeDuplicates { before, after in
                before.currentState == after.currentState
            }
            .map { data in
                data.currentState
            }
            .sink { currentState in
                self.currentState = currentState
            }
            .store(in: &cancellables)
        
        manager.$data
            .removeDuplicates { before, after in
                before.completedPomodoros == after.completedPomodoros
            }
            .map { data in
                data.completedPomodoros
            }
            .sink { completedPomodoros in
                self.completedPomodoros = completedPomodoros
            }
            .store(in: &cancellables)
        
        manager.$data
            .sink { data in
                self.percentTimeRemaining = data.percentTimeRemaining()
            }
            .store(in: &cancellables)
    }
    
    private func startTimer(duration: Double) {
        let timeInterval = 0.02
        manager.decrementTimeRemaining(delta: timeInterval)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
            self.manager.decrementTimeRemaining(delta: timeInterval)
            if !self.manager.data.timerInProgress {
                self.timer?.invalidate()
            }
        }
    }
    
    func start(pomodoroStep: PomodoroStep) {
        manager.start(step: pomodoroStep)
        
        switch pomodoroStep {
        case .pomodoro:
            startTimer(duration: manager.data.pomodoroDuration)
        case .shortBreak:
            startTimer(duration: manager.data.shortBreakDuration)
        case .longBreak:
            startTimer(duration: manager.data.longBreakDuration)
        }
    }
}

