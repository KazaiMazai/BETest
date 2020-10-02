//
//  PrompterAvailableForSpeechTests.swift
//  BETestTests
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import XCTest
@testable import BETest

class PrompterAvailableForSpeechTests: XCTestCase {
    let delay = 0.5

    var animationDuration : TimeInterval {
        delay
    }

    var shortDelay: TimeInterval {
        delay / 2
    }

    let testData = [
        TextData(id: 0, text: "Some text0"),
        TextData(id: 1, text: "Some text1"),
        TextData(id: 2, text: "Some text2"),
        TextData(id: 3, text: "Some text3"),
        TextData(id: 4, text: "Some text4")
    ]

    func test_WhenFirstItemAppearAndDelayPass_ItemAvailableForSpeech() {
        var prompter = Prompter(delay: delay)

        let actions: [Action] = [
            Actions.PrompterFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { prompter.reduce($0) }
        prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))
        XCTAssertNotNil(prompter.availableForSpeech(at: Date().addingTimeInterval(animationDuration + delay)),
                        "Item should be available for speech after delay interval")
    }

    func test_WhenFirstItemAppearAndDelayDidNotPass_NoItemsAvailableForSpeech() {
        var prompter = Prompter(delay: delay)

        let actions: [Action] = [
            Actions.PrompterFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { prompter.reduce($0) }
        prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration)))
        XCTAssertNil(prompter.availableForSpeech(at: Date().addingTimeInterval(animationDuration)),
                        "Item should not be available for speech until delay intervals pass")
    }

    func test_WhenSpeechFinishAndDelayDidNotPass_ItemIsNotAvailableForSpeech() {
        var prompter = Prompter(delay: delay)

        let actions: [Action] = [
            Actions.PrompterFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { prompter.reduce($0) }
        prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))

        prompter.reduce(Actions.SpeechSynthesizer.StateChange(state: .start))
        prompter.reduce(Actions.SpeechSynthesizer.StateChange(state: .finish))
        prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(shortDelay)))

        XCTAssertNil(prompter.availableForSpeech(at: Date().addingTimeInterval(shortDelay)),
                        "Item should not be available for speech when speech finished")
    }

    func test_WhenSpeechDidNotFinishYet_ItemIsAvailableForSpeech() {
        var prompter = Prompter(delay: delay)

        let actions: [Action] = [
            Actions.PrompterFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { prompter.reduce($0) }
        prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))

        prompter.reduce(Actions.SpeechSynthesizer.StateChange(state: .start))

        prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(shortDelay)))

        XCTAssertNil(prompter.availableForSpeech(at: Date().addingTimeInterval(shortDelay)),
                        "Item should be available for speech when speech in progress")
    }

    func test_WhenAllItemsProcessed_NothingIsAvaliableForSpeech() {
        var prompter = Prompter(delay: delay)

        let actions: [Action] = [
            Actions.PrompterFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { prompter.reduce($0) }
        testData.forEach { item in
            prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))
            XCTAssertNotNil(prompter.availableForSpeech(at: Date().addingTimeInterval(animationDuration + delay)),
                            "Item should be available for speech after delay interval")
            XCTAssertEqual(
                item.id,
                prompter.availableForSpeech(at: Date().addingTimeInterval(animationDuration + delay))?.payload.id,
                "Item should be available for speech after delay interval")
            prompter.reduce(Actions.SpeechSynthesizer.StateChange(state: .start))
            prompter.reduce(Actions.SpeechSynthesizer.StateChange(state: .finish))
            prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(delay)))
        }

        XCTAssertNil(prompter.availableForSpeech(at: Date().addingTimeInterval(animationDuration)),
                        "Item should not be available for speech after all of them processed")
    }
}
