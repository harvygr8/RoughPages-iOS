//
//  RoundedRectangleBtn.swift
//  RoughPages
//
//  Created by Pranjal Chaudhari on 13/04/23.
//

import SwiftUI

struct RoundedRectangleBtn: View {
    var title:String
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color("primary_blue"))
            HStack{
                Text(title).font(.custom("Poppins-Regular", size: 20)).foregroundColor(.black)
            }
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: 50)
    }
}

struct RoundedRectangleBtn_Previews: PreviewProvider {
    static var previews: some View {
        RoundedRectangleBtn(title: "Title")
    }
}
