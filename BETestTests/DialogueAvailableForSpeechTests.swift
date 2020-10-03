//
//  DialogueAvailableForSpeechTests.swift
//  BETestTests
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import XCTest
@testable import BETest

class DialogueAvailableForSpeechTests: XCTestCase {
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


    func makeTestDialogue() -> Dialogue {
        Dialogue(delay: delay, file: .init(filename: ""))
    }


    func test_WhenFirstItemAppearAndDelayPass_ItemAvailableForSpeech() {
        var dialogue = makeTestDialogue()

        let actions: [Action] = [
            Actions.DialogueFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { dialogue.reduce($0) }
        dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))
        XCTAssertNotNil(dialogue.availableForSpeech(at: Date().addingTimeInterval(animationDuration + delay)),
                        "Item should be available for speech after delay interval")
    }

    func test_WhenFirstItemAppearAndDelayDidNotPass_NoItemsAvailableForSpeech() {
        var dialogue = makeTestDialogue()

        let actions: [Action] = [
            Actions.DialogueFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { dialogue.reduce($0) }
        dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration)))
        XCTAssertNil(dialogue.availableForSpeech(at: Date().addingTimeInterval(animationDuration)),
                        "Item should not be available for speech until delay intervals pass")
    }

    func test_WhenSpeechFinishAndDelayDidNotPass_ItemIsNotAvailableForSpeech() {
        var dialogue = makeTestDialogue()

        let actions: [Action] = [
            Actions.DialogueFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { dialogue.reduce($0) }
        dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))

        dialogue.reduce(Actions.SpeechSynthesizer.StateChange(state: .start))
        dialogue.reduce(Actions.SpeechSynthesizer.StateChange(state: .finish))
        dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(shortDelay)))

        XCTAssertNil(dialogue.availableForSpeech(at: Date().addingTimeInterval(shortDelay)),
                        "Item should not be available for speech when speech finished")
    }

    func test_WhenSpeechDidNotFinishYet_ItemIsAvailableForSpeech() {
        var dialogue = makeTestDialogue()

        let actions: [Action] = [
            Actions.DialogueFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { dialogue.reduce($0) }
        dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))

        dialogue.reduce(Actions.SpeechSynthesizer.StateChange(state: .start))

        dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(shortDelay)))

        XCTAssertNil(dialogue.availableForSpeech(at: Date().addingTimeInterval(shortDelay)),
                        "Item should be available for speech when speech in progress")
    }

    func test_WhenAllItemsProcessed_NothingIsAvaliableForSpeech() {
        var dialogue = makeTestDialogue()

        let actions: [Action] = [
            Actions.DialogueFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { dialogue.reduce($0) }
        testData.forEach { item in
            dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))
            XCTAssertNotNil(dialogue.availableForSpeech(at: Date().addingTimeInterval(animationDuration + delay)),
                            "Item should be available for speech after delay interval")
            XCTAssertEqual(
                item.id,
                dialogue.availableForSpeech(at: Date().addingTimeInterval(animationDuration + delay))?.payload.id,
                "Item should be available for speech after delay interval")
            dialogue.reduce(Actions.SpeechSynthesizer.StateChange(state: .start))
            dialogue.reduce(Actions.SpeechSynthesizer.StateChange(state: .finish))
            dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(delay)))
        }

        XCTAssertNil(dialogue.availableForSpeech(at: Date().addingTimeInterval(animationDuration)),
                        "Item should not be available for speech after all of them processed")
    }
}
