//
//  FormatSheetView.swift
//  roughpages
//
//  Created by Pranjal Chaudhari on 04/05/23.
//

import SwiftUI

struct FormatSheetView: View {
    @State var isBoldActive = false
    @State var isItalicActive = false
    @State var isUnderlineActive = false
    @State var isStrikethoughActive = false
    @State private var sheetHeight: CGFloat = .zero
    @Environment(\.dismiss) var dismiss
    @Binding var text: String
    @Binding var selectedRange: NSRange
    
    var body: some View {
        VStack{
            HStack{
                Text("Format").font(.custom("Poppins-Regular", size: 24))
                Spacer()
                Image(systemName: "xmark.circle.fill").resizable().frame(width: 25,height: 25).onTapGesture {
                    dismiss()
                }
            }
            HStack(spacing: 2){
                Text("B").bold().frame(maxWidth: .infinity).padding().background(isBoldActive ? Color("format_blue") : Color("grey")).cornerRadius(10, corners: [.topLeft, .bottomLeft])
                    .onTapGesture {
                        isBoldActive.toggle()
                        applyBoldFormat()
                        dismiss()
                    }
                Text("I").italic().frame(maxWidth: .infinity).padding().background(isItalicActive ? Color("format_blue") : Color("grey"))
                    .onTapGesture {
                        isItalicActive.toggle()
                        applyItalicFormat()
                        dismiss()
                    }
//                Text("U").underline().frame(maxWidth: .infinity).padding().background(isUnderlineActive ? Color("format_blue") : Color("grey"))
//                    .onTapGesture {
//                        isUnderlineActive.toggle()
//                    }
                Text("S").strikethrough().frame(maxWidth: .infinity).padding().background(isStrikethoughActive ? Color("format_blue") : Color("grey")).cornerRadius(10, corners: [.topRight, .bottomRight])
                    .onTapGesture {
                        isStrikethoughActive.toggle()
                        applyStrikeThroughFormat()
                        dismiss()
                    }
            }
        }.padding()
            .overlay {
                GeometryReader { geometry in
                    Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
                }
            }
            .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                sheetHeight = newHeight
            }
            .presentationDetents([.height(sheetHeight)])
        
    }
    
    func applyBoldFormat() {
        let s = selectedRange.location
        let e = selectedRange.location + selectedRange.length
        var t = text.substring(with: s..<e)
        print(t)
        let p1 = text.substring(to: s)
        let p3 = text.substring(from: e)
        if isBoldActive {
            text = p1 + "**\(t)**" + p3
            //selectedRange.location = selectedRange.location - 2 < 0 ? 0 : selectedRange.location - 2
            selectedRange.length = selectedRange.length + 4
        }else{
            let s2 = s + 2
            let e2 = e - 2
            t = text.substring(with: s2..<e2)
            text = p1 + "\(t)" + p3
            //selectedRange.location = selectedRange.location - 2 < 0 ? 0 : selectedRange.location - 2
            selectedRange.length = selectedRange.length - 4
        }
        
    }
    
    func applyItalicFormat() {
        let s = selectedRange.location
        let e = selectedRange.location + selectedRange.length
        var t = text.substring(with: s..<e)
        print(t)
        let p1 = text.substring(to: s)
        let p3 = text.substring(from: e)
        if isItalicActive {
            text = p1 + "*\(t)*" + p3
            //selectedRange.location = selectedRange.location - 2 < 0 ? 0 : selectedRange.location - 2
            selectedRange.length = selectedRange.length + 2
        }else{
            let s2 = s + 2
            let e2 = e - 2
            t = text.substring(with: s2..<e2)
            text = p1 + "\(t)" + p3
            //selectedRange.location = selectedRange.location - 2 < 0 ? 0 : selectedRange.location - 2
            selectedRange.length = selectedRange.length - 2
        }

    }
    
    func applyStrikeThroughFormat(){
        let s = selectedRange.location
        let e = selectedRange.location + selectedRange.length
        var t = text.substring(with: s..<e)
        print(t)
        let p1 = text.substring(to: s)
        let p3 = text.substring(from: e)
        if isStrikethoughActive {
            text = p1 + "~~\(t)~~" + p3
            //selectedRange.location = selectedRange.location - 2 < 0 ? 0 : selectedRange.location - 2
            selectedRange.length = selectedRange.length + 4
        }else{
            let s2 = s + 2
            let e2 = e - 2
            t = text.substring(with: s2..<e2)
            text = p1 + "\(t)" + p3
            //selectedRange.location = selectedRange.location - 2 < 0 ? 0 : selectedRange.location - 2
            selectedRange.length = selectedRange.length - 4
        }
    }
}

//struct FormatSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        FormatSheetView(text: <#T##Binding<String>#>)
//    }
//}
