//
//  AddTag.swift
//  roughpages
//
//  Created by Pranjal Chaudhari on 03/05/23.
//

import SwiftUI
import WrappingHStack

struct AddTag: View {
    @Environment(\.dismiss) var dismiss
    @Binding var tags: [String]
    @State var tagValue = ""

    var body: some View {
        VStack{
            Text("Add tags")
            TextField("Tag",text: $tagValue).onSubmit {
                tags.append(tagValue)
                tagValue = ""
            }.textFieldStyle(.roundedBorder)
            WrappingHStack(tags) { model in
              Text(model)
                    .padding(.all, 5)
                    .font(.body)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
            }
            Spacer()
            RoundedRectangleBtn(title: "Save").onTapGesture {
                dismiss()
            }
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
        .padding()
    }
}

//struct AddTag_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTag(tags: t)
//    }
//}
