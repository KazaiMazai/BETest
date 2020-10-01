//
//  PrompterTests.swift
//  BETestTests
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import XCTest
@testable import BETest

class PrompterItemsArrayTests: XCTestCase {
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

    let testData = [
        TextData(id: 0, text: "Some text0"),
        TextData(id: 1, text: "Some text1"),
        TextData(id: 2, text: "Some text2"),
        TextData(id: 3, text: "Some text3"),
        TextData(id: 4, text: "Some text4")
    ]

    func test_WhenDataReceived_FirstItemPresents() {
        var prompter = Prompter(delay: delay)

        let actions: [Action] = [
            Actions.PrompterFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { prompter.reduce($0) }

        XCTAssertEqual(prompter.items.count, 1, "1 item should present after data received")
    }

    func test_WhenOneAnimationIntervalsPass_OnlyFirstItemPresents() {
        var prompter = Prompter(delay: delay)

        let actions: [Action] = [
            Actions.PrompterFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { prompter.reduce($0) }
        prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration)))

        XCTAssertEqual(prompter.items.count, 1, "1 item should present after 1 delay interval")
    }

    func test_WhenLongDelayIntervalsPassAndNoSpeakerFinishEvent_OneItemPresents() {
        var prompter = Prompter(delay: delay)

        let actions: [Action] = [
            Actions.PrompterFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { prompter.reduce($0) }
        prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(longDelay)))

        XCTAssertEqual(prompter.items.count, 1, "1 item should present after long delay interval and no speech finish event")
    }

    func test_WhenFirstItemSpeechFinishedAndDelayDidNotPass_OneItemPresents() {
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

        XCTAssertEqual(prompter.items.count, 1, "1 items should present after speech finished and delay interval did not pass")
    }

    func test_WhenFirstItemSpeechFinishedAndDelayPass_TwoItemsPresent() {
        var prompter = Prompter(delay: delay)

        let actions: [Action] = [
            Actions.PrompterFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { prompter.reduce($0) }
        prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))
        prompter.reduce(Actions.SpeechSynthesizer.StateChange(state: .start))
        prompter.reduce(Actions.SpeechSynthesizer.StateChange(state: .finish))
        prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(delay)))

        XCTAssertEqual(prompter.items.count, 2, "2 items should present after speech finished and delay interval passed")
    }

    func test_WhenAllItemsProcessed_AllItemsPresent() {
        var prompter = Prompter(delay: delay)

        let actions: [Action] = [
            Actions.PrompterFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { prompter.reduce($0) }
        testData.forEach { _ in
            prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))
            prompter.reduce(Actions.SpeechSynthesizer.StateChange(state: .start))
            prompter.reduce(Actions.SpeechSynthesizer.StateChange(state: .finish))
            prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(delay)))
        }


        XCTAssertEqual(prompter.items.count, testData.count, "All items should present after speech finished and delay interval passed for all of them")
    }

    func test_WhenAllItemsProcessedGradually_CurrentIterationItemsAvailable() {
        var prompter = Prompter(delay: delay)

        let actions: [Action] = [
            Actions.PrompterFlow.Run(),
            Actions.TextDataSource.ReceievedDataSuccess(value: testData)
        ]

        actions.forEach { prompter.reduce($0) }
        testData.enumerated().forEach {
            let currentItemsOffsetCount = $0.offset + 1
            XCTAssertEqual(prompter.items.count, currentItemsOffsetCount, "Current items should present")

            prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(animationDuration + delay)))

            XCTAssertEqual(prompter.items.count, currentItemsOffsetCount, "Current items should present")

            prompter.reduce(Actions.SpeechSynthesizer.StateChange(state: .start))

            XCTAssertEqual(prompter.items.count, currentItemsOffsetCount, "Current items should present")

            prompter.reduce(Actions.SpeechSynthesizer.StateChange(state: .finish))

            XCTAssertEqual(prompter.items.count, currentItemsOffsetCount, "Current items should present")

            prompter.reduce(Actions.Time.TimeChanged(timestamp: Date().addingTimeInterval(delay)))
        }
    }
}
