//
//  Merging.swift
//  BETest
//
//  Created by Sergey Kazakov on 21.05.2021.
//

import Foundation

struct Merging<Existing, New> {
    let merge: (Existing, New) -> Existing

    static var replace: Merging<Existing, Existing> {
        Merging<Existing, Existing>(merge: { _, new in new })
    }
}
