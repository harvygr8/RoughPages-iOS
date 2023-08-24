//
//  UITextViewRepresentable.swift
//  roughpages
//
//  Created by Pranjal Chaudhari on 03/05/23.
//

import Foundation
import SwiftUI

struct UITextViewRepresentable: UIViewRepresentable {
    let textView = UITextView()
    @Binding var text: String
    @Binding var selectedRange: NSRange
    @Binding var didStartEditing: Bool
    
    func makeUIView(context: Context) -> UITextView {
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.selectedRange = NSRange(location: 0, length: 0)
        textView.isUserInteractionEnabled = true
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // swfit to uikit
        if didStartEditing {
            uiView.textColor = UIColor.black
            uiView.text = text
        }
        else {
            uiView.text = "Type something..."
            uiView.textColor = UIColor.lightGray
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UITextViewRepresentable

        init(_ parent: UITextViewRepresentable) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // uikit to swiftui
            parent.text = textView.text
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            print(textView.selectedRange)
            parent.selectedRange = textView.selectedRange
        }
    }
}
