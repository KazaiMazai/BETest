//
//  File.swift
//  BETest
//
//  Created by Sergey Kazakov on 03.10.2020.
//

import SwiftUI

class DarkHostingController<ContentView> : UIHostingController<ContentView> where ContentView : View {
    override dynamic open var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
}
