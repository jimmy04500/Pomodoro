//
//  PomodoroTests.swift
//  PomodoroTests
//
//  Created by Edward Kim on 5/25/23.
//

import XCTest
@testable import Pomodoro

final class PomodoroTests: XCTestCase {
    var sut: PomodoroManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = PomodoroManager()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }

    func testPomodoroManager_whenInitialized_hasCorrectState() {
        XCTAssertEqual(sut.data.currentStep, .pomodoro)
        XCTAssertEqual(sut.data.currentState, .notStarted)
        XCTAssertEqual(sut.data.timeRemaining, 0)
        XCTAssertEqual(sut.data.timerInProgress, false)
        XCTAssertEqual(sut.data.completedPomodoros, 0)
    }
    
    func testPomodoroStep_whenStarted_hasCorrectState() throws {
        sut.start(step: .pomodoro)
        XCTAssertEqual(sut.data.currentStep, .pomodoro)
        XCTAssertEqual(sut.data.currentState, .inProgress)
        XCTAssertEqual(sut.data.timeRemaining, sut.data.pomodoroDuration)
        XCTAssertEqual(sut.data.timerInProgress, true)
        XCTAssertEqual(sut.data.completedPomodoros, 0)
    }
    
    func testPomodoroStep_whenPaused_hasCorrectState() throws {
        sut.start(step: .pomodoro)
        sut.decrementTimeRemaining(delta: 0.1)
        sut.pause(step: .pomodoro)
        XCTAssertEqual(sut.data.currentStep, .pomodoro)
        XCTAssertEqual(sut.data.currentState, .paused)
        XCTAssertEqual(sut.data.timeRemaining, sut.data.pomodoroDuration - 0.1)
        XCTAssertEqual(sut.data.timerInProgress, false)
        XCTAssertEqual(sut.data.completedPomodoros, 0)
    }
    
    func testPomodoroStep_whenResumed_hasCorrectState() throws {
        sut.start(step: .pomodoro)
        sut.decrementTimeRemaining(delta: 0.1)
        sut.pause(step: .pomodoro)
        sut.resume(step: .pomodoro)
        XCTAssertEqual(sut.data.currentStep, .pomodoro)
        XCTAssertEqual(sut.data.currentState, .inProgress)
        XCTAssertEqual(sut.data.timeRemaining, sut.data.pomodoroDuration - 0.1)
        XCTAssertEqual(sut.data.timerInProgress, true)
        XCTAssertEqual(sut.data.completedPomodoros, 0)
    }
    
    func testPomodoroStep_whenStoppedFromInProgress_hasCorrectState() throws {
        sut.start(step: .pomodoro)
        sut.decrementTimeRemaining(delta: sut.data.pomodoroDuration)
        sut.stop()
        XCTAssertEqual(sut.data.currentStep, .pomodoro)
        XCTAssertEqual(sut.data.currentState, .notStarted)
        XCTAssertEqual(sut.data.timeRemaining, 0)
        XCTAssertEqual(sut.data.timerInProgress, false)
        XCTAssertEqual(sut.data.completedPomodoros, 0)
    }
    
    func testPomodoroStep_whenFinished_hasCorrectState() throws {
        sut.start(step: .pomodoro)
        sut.decrementTimeRemaining(delta: sut.data.pomodoroDuration)
        XCTAssertEqual(sut.data.currentStep, .shortBreak)
        XCTAssertEqual(sut.data.currentState, .notStarted)
        XCTAssertEqual(sut.data.timeRemaining, 0)
        XCTAssertEqual(sut.data.timerInProgress, false)
        XCTAssertEqual(sut.data.completedPomodoros, 1)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
