//
//  Command.swift
//  BETest
//
//  Created by Sergey Kazakov on 01.10.2020.
//

import Foundation

typealias Command = () -> Void
typealias CommandWith<T> = (T) -> Void

func nop() {}
func nop<T>(_ value: T) {}
