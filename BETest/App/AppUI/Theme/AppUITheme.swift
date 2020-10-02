//
//  AppUITheme.swift
//  BETest
//
//  Created by Sergey Kazakov on 02.10.2020.
//

import SwiftUI
import UIKit

struct AppUITheme {
    let baloonStyle: BaloonStyle
    let dialogueViewStyle: DialogueViewStyle
    let navBarStyle: NavBarStyle

    static var defaultTheme: AppUITheme {
        .init(baloonStyle: BaloonStyle(),
              dialogueViewStyle: DialogueViewStyle(),
              navBarStyle: NavBarStyle())
    }
}

extension AppUITheme {
    struct NavBarStyle {
        let titleColor = Color.black
        let backgroundColor = Color(red: 247.0 / 255.0,  green: 247.0 / 255.0, blue: 247.0 / 255.0)
        let separatorColor = Color(red: 210.0 / 255.0,  green: 210.0 / 255.0, blue: 210.0 / 255.0)
        let titleFont = Font.system(size: 17, weight: .semibold)
        let height: CGFloat = 44
    }

    struct DialogueViewStyle {
        let backgroundColor = Color(hex: "#F9FAFB")
    }

    struct BaloonStyle {
        let font = Font.system(size: 17, weight: .light) //Font.custom(".SFUIText-Light", size: 17)
        let textColor = Color(hex: "#000000")
        let backgroundColor = Color(hex: "#FDFDFE")
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
        let maxWidthProportion: CGFloat = 0.75
    }
}
