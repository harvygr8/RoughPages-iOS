//
//  Extensions.swift
//  RoughPages
//
//  Created by Pranjal Chaudhari on 15/04/23.
//

import Foundation
import SwiftUI


//EXTENSION METHODS 
extension View {
    func hidden(_ shouldHide: Bool) -> some View {
            opacity(shouldHide ? 0 : 1)
    }
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }

}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIdx = index(from: from)
        return String(self[fromIdx...])
    }

    func substring(to: Int) -> String {
        let toIdx = index(from: to)
        return String(self[..<toIdx])
    }

    func substring(with r: Range<Int>) -> String {
        let startIdx = index(from: r.lowerBound)
        let endIdx = index(from: r.upperBound)
        return String(self[startIdx..<endIdx])
    }
}

extension Array where Element: Equatable {
    
    mutating func remove(object: Element) {
        guard let idx = firstIndex(of: object) else {return}
        remove(at: idx)
    }
    
}


struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


