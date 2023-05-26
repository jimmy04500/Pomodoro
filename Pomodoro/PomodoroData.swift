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
//    enum State {
//        case PomodoroNotStarted()
//        case PomodoroInProgress(numPomosFinished: Int, timeRemaining: Int)
//        case ShortBreakNotStarted(numPomosFinished: Int)
//        case ShortBreakInProgress(numPomosFinished: Int, timeRemaining: Int)
//        case LongBreakNotStarted(numPomosFinished: Int)
//        case LongBreakInProgress(numPomosFinished: Int, timeRemaining: Int)
//    }
    var currentStep: PomodoroType
    var timeRemaining: Int
    var completedPomodoros: Int
    
    var pomodoroDuration = 5
    var shortBreakDuration = 5
    var longBreakDuration = 5
    var numPomosForLongBreak = 4
}

class PomodoroViewModel: ObservableObject {
    private var data: PomodoroData = PomodoroData(currentStep: .PomodoroNotStarted, timeRemaining: 0, completedPomodoros: 0)
    private var timer: Timer? = nil
    
    @Published var displayTimeRemaining = "00:00"
    @Published var currentStep = PomodoroType.PomodoroNotStarted
    @Published var completedPomodoros = 0
    
    func startPomodoro() {
        guard data.currentStep == .PomodoroNotStarted else {
            fatalError("Invalid state for startPomodoro \(data.currentStep)")
        }
        
        data.currentStep = .PomodoroInProgress
        currentStep = .PomodoroInProgress
        
        data.timeRemaining = data.pomodoroDuration
        var minutes = data.timeRemaining / 60
        var seconds = data.timeRemaining % 60
        displayTimeRemaining = String(format: "%02d:%02d", minutes, seconds)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.data.timeRemaining -= 1
            
            let minutes = self.data.timeRemaining / 60
            let seconds = self.data.timeRemaining % 60
            self.displayTimeRemaining = String(format: "%02d:%02d", minutes, seconds)
            
            if self.data.timeRemaining == 0 {
                self.timer?.invalidate()
                self.data.completedPomodoros += 1
                if self.data.completedPomodoros == self.data.numPomosForLongBreak {
                    self.data.currentStep = .LongBreakNotStarted
                    self.currentStep = .LongBreakNotStarted
                    self.data.completedPomodoros = 0
                } else {
                    self.data.currentStep = .ShortBreakNotStarted
                    self.currentStep = .ShortBreakNotStarted
                }
            }
            self.completedPomodoros = self.data.completedPomodoros
        }
    }
    
    func startShortBreak() {
        guard data.currentStep == .ShortBreakNotStarted else {
            fatalError("Invalid state for startPomodoro \(data.currentStep)")
        }
        
        data.currentStep = .ShortBreakInProgress
        currentStep = .ShortBreakInProgress
        
        data.timeRemaining = data.shortBreakDuration
        var minutes = data.timeRemaining / 60
        var seconds = data.timeRemaining % 60
        displayTimeRemaining = String(format: "%02d:%02d", minutes, seconds)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.data.timeRemaining -= 1
            
            let minutes = self.data.timeRemaining / 60
            let seconds = self.data.timeRemaining % 60
            self.displayTimeRemaining = String(format: "%02d:%02d", minutes, seconds)
            
            if self.data.timeRemaining == 0 {
                self.timer?.invalidate()
                self.data.currentStep = .PomodoroNotStarted
                self.currentStep = .PomodoroNotStarted
            }
        }
    }
    
    func startLongBreak() {
        guard data.currentStep == .LongBreakNotStarted else {
            fatalError("Invalid state for startPomodoro \(data.currentStep)")
        }
        
        data.currentStep = .LongBreakInProgress
        currentStep = .LongBreakInProgress
        
        data.timeRemaining = data.longBreakDuration
        var minutes = data.timeRemaining / 60
        var seconds = data.timeRemaining % 60
        displayTimeRemaining = String(format: "%02d:%02d", minutes, seconds)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.data.timeRemaining -= 1
            
            let minutes = self.data.timeRemaining / 60
            let seconds = self.data.timeRemaining % 60
            self.displayTimeRemaining = String(format: "%02d:%02d", minutes, seconds)
            
            if self.data.timeRemaining == 0 {
                self.timer?.invalidate()
                self.data.currentStep = .PomodoroNotStarted
                self.currentStep = .PomodoroNotStarted
            }
        }
    }
}

