//
//  AppUITheme.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import SwiftUI

struct AppUITheme {
    init(baloonStyle: AppUITheme.BaloonStyle) {
        self.baloonStyle = baloonStyle
    }

    let baloonStyle: BaloonStyle

    static var defaultTheme: AppUITheme {
        .init(baloonStyle: BaloonStyle())
    }
}


extension AppUITheme {
    struct BaloonStyle {
        let font = Font.system(size: 17, weight: .light, design: Font.Design.serif)
    }
}
