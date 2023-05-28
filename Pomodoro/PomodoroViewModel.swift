//
//  TimerData.swift
//  Pomodoro
//
//  Created by Edward Kim on 5/25/23.
//

import Foundation
import Combine
import SwiftUI

class PomodoroViewModel: ObservableObject {
    private let manager = PomodoroManager()
    private var timer: Timer? = nil
    let timerDownAnimation: Animation = .linear(duration: 1.0)
    let timerResetAnimation: Animation = .easeInOut(duration: 0.5)
    
    @Published var displayTimeRemaining = "00:00"
    @Published var percentTimeRemaining = 1.0
    @Published var currentStep = PomodoroStep.pomodoro
    @Published var currentState = PomodoroState.notStarted
    @Published var completedPomodoros = 0
    @Published var animation = Animation.linear(duration: 1.0)
    
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
    }
    
    private func startTimer(duration: Double) {
        animation = timerDownAnimation
        let timeInterval = 1.0
        manager.decrementTimeRemaining(delta: timeInterval)
        percentTimeRemaining = manager.data.percentTimeRemaining()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
            if !self.manager.data.timerInProgress {
                self.timer?.invalidate()
                self.animation = self.timerResetAnimation
                self.percentTimeRemaining = 1.0
                return
            }
            self.animation = self.timerDownAnimation
            self.manager.decrementTimeRemaining(delta: timeInterval)
            self.percentTimeRemaining = self.manager.data.percentTimeRemaining()
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
    
    func pause(pomodoroStep: PomodoroStep) {
        manager.pause(step: pomodoroStep)
    }
    
    func resume(pomodoroStep: PomodoroStep) {
        manager.resume(step: pomodoroStep)
        startTimer(duration: manager.data.timeRemaining)
    }
    
    func stop() {
        manager.stop()
    }
}

