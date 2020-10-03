//
//  DialogueTests.swift
//  BETestTests
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import XCTest
@testable import BETest

class DialogueItemsArrayTests: XCTestCase {
    let delay = 0.5

    var animationDuration : TimeInterval {
        delay
    }

    var shortDelay: TimeInterval {
        delay / 2
    }

    var longDelay: TimeInterval {
        delay * 4
    }

    func makeTestDialogue() -> Dialogue {
        Dialogue(delay: delay)
    }


    let testData = [
        TextData(id: 0, text: "Some text0"),
        TextData(id: 1, text: "Some text1"),
        TextData(id: 2, text: "Some text2"),
        TextData(id: 3, text: "Some text3"),
        TextData(id: 4, text: "Some text4")
    ]

    func test_WhenDataReceived_FirstItemPresents() {
        var dialogue = makeTestDialogue()

        let actions: [Action] = [
            Actions.DialogueFlow.Run(filename: ""),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { dialogue.reduce($0) }

        XCTAssertEqual(dialogue.items.count, 1, "1 item should present after data received")
    }

    func test_WhenDataWithEmptyItemsReceived_EmptyItemsFiltered() {
        var dialogue = makeTestDialogue()

        var data = testData
        data.append(TextData(id: 5, text: "")) 

        let actions: [Action] = [
            Actions.DialogueFlow.Run(filename: ""),
            Actions.TextDataSource.ReceievedDataSuccess(value: data)
        ]

        actions.forEach { dialogue.reduce($0) }

        XCTAssertEqual(dialogue.pendingItems.count + dialogue.items.count, testData.count, "Empty text item should filtered")
    }


    func test_WhenOneAnimationIntervalsPass_OnlyFirstItemPresents() {
        var dialogue = makeTestDialogue()

        let actions: [Action] = [
            Actions.DialogueFlow.Run(filename: ""),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { dialogue.reduce($0) }
        dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration)))

        XCTAssertEqual(dialogue.items.count, 1, "1 item should present after 1 delay interval")
    }

    func test_WhenLongDelayIntervalsPassAndNoSpeakerFinishEvent_OneItemPresents() {
        var dialogue = makeTestDialogue()

        let actions: [Action] = [
            Actions.DialogueFlow.Run(filename: ""),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { dialogue.reduce($0) }
        dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(longDelay)))

        XCTAssertEqual(dialogue.items.count, 1, "1 item should present after long delay interval and no speech finish event")
    }

    func test_WhenFirstItemSpeechFinishedAndDelayDidNotPass_OneItemPresents() {
        var dialogue = makeTestDialogue()

        let actions: [Action] = [
            Actions.DialogueFlow.Run(filename: ""),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { dialogue.reduce($0) }
        dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))
        dialogue.reduce(Actions.SpeechSynthesizer.StateChange(state: .start))
        dialogue.reduce(Actions.SpeechSynthesizer.StateChange(state: .finish))
        dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(shortDelay)))

        XCTAssertEqual(dialogue.items.count, 1, "1 items should present after speech finished and delay interval did not pass")
    }

    func test_WhenFirstItemSpeechFinishedAndDelayPass_TwoItemsPresent() {
        var dialogue = makeTestDialogue()

        let actions: [Action] = [
            Actions.DialogueFlow.Run(filename: ""),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { dialogue.reduce($0) }
        dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))
        dialogue.reduce(Actions.SpeechSynthesizer.StateChange(state: .start))
        dialogue.reduce(Actions.SpeechSynthesizer.StateChange(state: .finish))
        dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(delay)))

        XCTAssertEqual(dialogue.items.count, 2, "2 items should present after speech finished and delay interval passed")
    }

    func test_WhenAllItemsProcessed_AllItemsPresent() {
        var dialogue = makeTestDialogue()

        let actions: [Action] = [
            Actions.DialogueFlow.Run(filename: ""),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { dialogue.reduce($0) }
        testData.forEach { _ in
            dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))
            dialogue.reduce(Actions.SpeechSynthesizer.StateChange(state: .start))
            dialogue.reduce(Actions.SpeechSynthesizer.StateChange(state: .finish))
            dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(delay)))
        }


        XCTAssertEqual(dialogue.items.count, testData.count, "All items should present after speech finished and delay interval passed for all of them")
    }

    func test_WhenAllItemsProcessedGradually_CurrentIterationItemsAvailable() {
        var dialogue = makeTestDialogue()

        let actions: [Action] = [
            Actions.DialogueFlow.Run(filename: ""),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { dialogue.reduce($0) }
        testData.enumerated().forEach {
            let currentItemsOffsetCount = $0.offset + 1
            XCTAssertEqual(dialogue.items.count, currentItemsOffsetCount, "Current items should present")

            dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))

            XCTAssertEqual(dialogue.items.count, currentItemsOffsetCount, "Current items should present")

            dialogue.reduce(Actions.SpeechSynthesizer.StateChange(state: .start))

            XCTAssertEqual(dialogue.items.count, currentItemsOffsetCount, "Current items should present")

            dialogue.reduce(Actions.SpeechSynthesizer.StateChange(state: .finish))

            XCTAssertEqual(dialogue.items.count, currentItemsOffsetCount, "Current items should present")

            dialogue.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(delay)))
        }
    }
}
