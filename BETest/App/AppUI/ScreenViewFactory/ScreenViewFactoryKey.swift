//
//  ScreenViewFactoryKey.swift
//  BETest
//
//  Created by Sergey Kazakov on 23.05.2021.
//

import SwiftUI

struct ScreenViewFactoryKey: EnvironmentKey {
    static let defaultValue: ScreenViewsFactoryProtocol = ScreenViewsFactory.defaultScreenViewsFactory
}

extension EnvironmentValues {
    var screenViewsFactory: ScreenViewsFactoryProtocol {
        get { self[ScreenViewFactoryKey.self] }
        set { self[ScreenViewFactoryKey.self] = newValue }
    }
}
