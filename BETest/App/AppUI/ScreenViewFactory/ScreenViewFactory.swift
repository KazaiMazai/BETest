//
//  ScreenViewFactory.swift
//  BETest
//
//  Created by Sergey Kazakov on 23.05.2021.
//

import SwiftUI

protocol ScreenViewsFactoryProtocol {
    func makeView(for type: ScreenViews) -> AnyView
}

struct ScreenViewsFactory: ScreenViewsFactoryProtocol {
    func makeView(for type: ScreenViews) -> AnyView {
        switch type {
        case .dialogue:
            return DialoguePresenter().eraseToAnyView
        }
    }
}

extension ScreenViewsFactory {
    static let defaultScreenViewsFactory: ScreenViewsFactory =  {
        ScreenViewsFactory()
    }()
}
