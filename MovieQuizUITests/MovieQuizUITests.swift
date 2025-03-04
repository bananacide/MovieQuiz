//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Алексей Витценко on 1.03.2025.
//

import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButoon() {
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5))
        
        app.buttons["Yes"].tap()
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertTrue(secondPoster.waitForExistence(timeout: 5))
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButoon() {
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5))
        
        app.buttons["No"].tap()
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertTrue(secondPoster.waitForExistence(timeout: 5))
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        let buttonNo = app.buttons["No"]
        for _ in 1...10 {
            XCTAssertTrue(buttonNo.waitForExistence(timeout: 5))
            buttonNo.tap()
        }

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }

    func testAlertDismiss() {
        let buttonYes = app.buttons["Yes"]
        for _ in 1...10 {
            XCTAssertTrue(buttonYes.waitForExistence(timeout: 5))
            buttonYes.tap()
        }
        
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons.firstMatch.tap()
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(indexLabel.label, "1/10")
    }
    
    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
