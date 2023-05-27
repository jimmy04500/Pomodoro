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
    var timeRemaining: Double
    var completedPomodoros: Int
    
    var pomodoroDuration: Double = 25 * 60
    var shortBreakDuration: Double = 5
    var longBreakDuration: Double = 5
    var numPomosForLongBreak: Int = 4
}

class PomodoroViewModel: ObservableObject {
    private var data: PomodoroData = PomodoroData(currentStep: .PomodoroNotStarted, timeRemaining: 0, completedPomodoros: 0) {
        didSet {
            let minutes = Int(data.timeRemaining / 60)
            let seconds = Int(data.timeRemaining.truncatingRemainder(dividingBy: 60))
            displayTimeRemaining = String(format: "%02d:%02d", minutes, seconds)
            
            switch currentStep {
            case .PomodoroInProgress:
                percentTimeRemaining = Double(data.timeRemaining) / Double(data.pomodoroDuration)
//                print("Percent time remaining \(percentTimeRemaining)")
            case .ShortBreakInProgress:
                percentTimeRemaining = Double(data.timeRemaining) / Double(data.shortBreakDuration)
//                print("Percent time remaining \(percentTimeRemaining)")
            case .LongBreakInProgress:
                percentTimeRemaining = Double(data.timeRemaining) / Double(data.longBreakDuration)
            default:
                percentTimeRemaining = 1
            }
            
            currentStep = data.currentStep
            completedPomodoros = data.completedPomodoros
        }
    }
    private var timer: Timer? = nil
    
    @Published var displayTimeRemaining = "00:00"
    @Published var percentTimeRemaining = 1.0
    @Published var currentStep = PomodoroType.PomodoroNotStarted
    @Published var completedPomodoros = 0
    
    private func startTimer(duration: Double, completion: @escaping () -> Void) {
        data.timeRemaining = duration
        
        let timeInterval = 0.02
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
            if self.data.timeRemaining <= 0 {
                self.timer?.invalidate()
                completion()
            } else {
                self.data.timeRemaining -= timeInterval
            }
        }
    }
    
    func startPomodoro() {
        guard data.currentStep == .PomodoroNotStarted else {
            print("Invalid state for startPomodoro \(data.currentStep)")
            return
        }
        
        data.currentStep = .PomodoroInProgress
        startTimer(duration: data.pomodoroDuration) {
            self.data.completedPomodoros += 1
            
            if self.data.completedPomodoros == self.data.numPomosForLongBreak {
                self.data.currentStep = .LongBreakNotStarted
                self.data.completedPomodoros = 0
                self.data.timeRemaining = self.data.longBreakDuration
            } else {
                self.data.currentStep = .ShortBreakNotStarted
                self.data.timeRemaining = self.data.shortBreakDuration
            }
        }
    }
    
    func startShortBreak() {
        guard data.currentStep == .ShortBreakNotStarted else {
            print("Invalid state for startPomodoro \(data.currentStep)")
            return
        }
        
        data.currentStep = .ShortBreakInProgress
        data.timeRemaining = data.shortBreakDuration
        startTimer(duration: data.shortBreakDuration) {
            self.data.currentStep = .PomodoroNotStarted
            self.data.timeRemaining = self.data.pomodoroDuration
        }
    }
    
    func startLongBreak() {
        guard data.currentStep == .LongBreakNotStarted else {
            print("Invalid state for startPomodoro \(data.currentStep)")
            return
        }
        
        data.currentStep = .LongBreakInProgress
        data.timeRemaining = data.longBreakDuration
        startTimer(duration: data.longBreakDuration) {
            self.data.currentStep = .PomodoroNotStarted
            self.data.timeRemaining = self.data.pomodoroDuration
        }
    }
}

