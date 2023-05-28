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
    case ShortBreakNotStarted
    case ShortBreakInProgress
    case LongBreakNotStarted
    case LongBreakInProgress
}

struct PomodoroData {
    var currentStep: PomodoroType
    var timeRemaining: TimeInterval
    var timerInProgress: Bool
    var completedPomodoros: Int
    
    var pomodoroDuration: Double = 5
    var shortBreakDuration: Double = 5
    var longBreakDuration: Double = 5
    var numPomosForLongBreak: Int = 4
    
    func percentTimeRemaining() -> Double {
        guard currentStep == .PomodoroInProgress ||
                currentStep == .ShortBreakInProgress ||
                currentStep == .LongBreakInProgress else {
            return 0.0
        }
        
        switch currentStep {
        case .PomodoroInProgress:
            return timeRemaining / pomodoroDuration
        case .ShortBreakInProgress:
            return timeRemaining / shortBreakDuration
        case .LongBreakInProgress:
            return timeRemaining / longBreakDuration
        default:
            fatalError("Invalid state \(currentStep)")
        }
    }
}

class PomodoroManager: ObservableObject {
    @Published var data: PomodoroData
    
    init() {
        data = PomodoroData(currentStep: .PomodoroNotStarted, timeRemaining: 0, timerInProgress: false, completedPomodoros: 0)
    }
    
    func decrementTimeRemaining(delta: TimeInterval) {
        guard data.currentStep == .PomodoroInProgress ||
                data.currentStep == .ShortBreakInProgress ||
                data.currentStep == .LongBreakInProgress else {
            fatalError("Invalid state \(data.currentStep)")
        }
        
        let resultTimeRemaining = data.timeRemaining - delta
        if resultTimeRemaining <= 0 {
            data.timerInProgress = false
            switch data.currentStep {
            case .PomodoroInProgress:
                data.completedPomodoros += 1
                if data.completedPomodoros == data.numPomosForLongBreak {
                    data.currentStep = .LongBreakNotStarted
                } else {
                    data.currentStep = .ShortBreakNotStarted
                }
            case .ShortBreakInProgress:
                data.currentStep = .PomodoroNotStarted
            case .LongBreakInProgress:
                data.completedPomodoros = 0
                data.currentStep = .PomodoroNotStarted
            default:
                print("Invalid state")
                return
            }
        } else {
            data.timeRemaining = resultTimeRemaining
        }
    }
    
    func startPomodoro() {
        guard data.currentStep == .PomodoroNotStarted else {
            return
        }
        
        data.currentStep = .PomodoroInProgress
        data.timeRemaining = data.pomodoroDuration
        data.timerInProgress = true
    }
    
//    func finishPomodoro() {
//
//    }
    
    func startShortBreak() {
        guard data.currentStep == .ShortBreakNotStarted else {
            return
        }
        
        data.currentStep = .ShortBreakInProgress
        data.timeRemaining = data.shortBreakDuration
        data.timerInProgress = true
    }
    
//    func finishShortBreak() {
//
//    }
    
    func startLongBreak() {
        guard data.currentStep == .LongBreakNotStarted else {
            return
        }
        
        data.currentStep = .LongBreakInProgress
        data.timeRemaining = data.longBreakDuration
        data.timerInProgress = true
    }
    
//    func finishLongBreak() {
//
//    }
}

class PomodoroViewModel: ObservableObject {
    private let manager = PomodoroManager()
    private var timer: Timer? = nil
    
    @Published var displayTimeRemaining = "00:00"
    @Published var percentTimeRemaining = 1.0
    @Published var currentStep = PomodoroType.PomodoroNotStarted
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
    
    func startPomodoro() {
        manager.startPomodoro()
        startTimer(duration: manager.data.pomodoroDuration)
    }
    
    func startShortBreak() {
        manager.startShortBreak()
        startTimer(duration: manager.data.shortBreakDuration)
    }
    
    func startLongBreak() {
        manager.startLongBreak()
        startTimer(duration: manager.data.longBreakDuration)
    }
}

