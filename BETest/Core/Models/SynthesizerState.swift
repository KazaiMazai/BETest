//
//  SynthesizerState.swift
//  BETest
//
//  Created by Sergey Kazakov on 21.05.2021.
//

import Foundation

enum SyntesizerState {
    case start
    case finish
    case pause
    case cancel
    case continued
    case failed(Error)
}
