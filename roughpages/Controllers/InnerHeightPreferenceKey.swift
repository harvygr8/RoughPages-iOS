//
//  InnerHeightPreferenceKey.swift
//  roughpages
//
//  Created by Pranjal Chaudhari on 04/05/23.
//

import Foundation
import SwiftUI

struct InnerHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
