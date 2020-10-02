//
//  AppUITheme.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import SwiftUI

struct AppUITheme {
    let baloonStyle: BaloonStyle
    let dialogueViewStyle: DialogueViewStyle


    static var defaultTheme: AppUITheme {
        .init(baloonStyle: BaloonStyle(),
              dialogueViewStyle: DialogueViewStyle())
    }
}

extension AppUITheme {
    struct DialogueViewStyle {
        let background = Color(hex: "#F9FAFB")
    }

    struct BaloonStyle {
        let font = Font.custom("SFProText-Light", size: 17)
        let textColor = Color(hex: "#000000")
        let background = Color(hex: "#FDFDFE")
        let borderRadius: CGFloat = 5
        let shadow = Shadow()
        let paddings = Paddings()
    }
}


extension AppUITheme.BaloonStyle {
    struct Shadow {
        let color = Color(hex: "#000000")
        let alpha: Double = 0.5
        let offset = CGSize(width: 1, height: 1)
        let blur: CGFloat = 4
    }
}

extension AppUITheme.BaloonStyle {
    struct Paddings {
        let interItemSpacing: CGFloat = 30
        let textPaddings: CGFloat = 10
        let leftContentInset: CGFloat = 20
        let leftBodyInset: CGFloat = 11
        let triangeSize = CGSize(width: 11, height: 18)
    }
}
