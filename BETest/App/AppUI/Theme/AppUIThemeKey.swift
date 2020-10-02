//
//  AppUIThemeKey.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import SwiftUI

struct AppUIThemeKey: EnvironmentKey {
    static let defaultValue: AppUITheme = .defaultTheme
}

extension EnvironmentValues {
    var appUITheme: AppUITheme {
        get { self[AppUIThemeKey.self] }
        set { self[AppUIThemeKey.self] = newValue }
    }
}
