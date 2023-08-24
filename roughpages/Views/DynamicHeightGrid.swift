//
//  DynamicHeightGrid.swift
//  roughpages
//
//  Created by Pranjal Chaudhari on 03/05/23.
//

import SwiftUI
import WrappingHStack

//Grid Cell
struct GridItem: Identifiable {
    let id  = UUID()
    var height: CGFloat
    let page: PageModel
    let color: Color
}

struct DynamicHeightGrid: View {
    
    struct Column: Identifiable {
        let id = UUID()
        var gridItems = [GridItem]()
    }
    
    let columns: [Column]
    
    let spacing: CGFloat
    let horizontalPadding: CGFloat
    let pageViewType: PageViewType
    @State var dh: [CGFloat] = [500]
    
    init(gridItems: [GridItem], numOfColumns: Int,pageViewType: PageViewType, spacing: CGFloat = 20, horizontalpadding: CGFloat = 20){
        self.spacing = spacing
        self.horizontalPadding = horizontalpadding
        self.pageViewType = pageViewType
        
        var columns = [Column]()
        for _ in 0 ..< numOfColumns {
            columns.append(Column())
        }
        
        var columnsHeight = Array<CGFloat>(repeating: 0, count: numOfColumns)
        
        for gridItem in gridItems {
            var smallestColumnIndex = 0
            var smallestHeight = columnsHeight.first!
            for i in 1 ..< columnsHeight.count {
                let curheight = columnsHeight[i]
                if curheight < smallestHeight {
                    smallestHeight = curheight
                    smallestColumnIndex = i
                }
            }
            
            columns[smallestColumnIndex].gridItems.append(gridItem)
            columnsHeight[smallestColumnIndex] += gridItem.height
        }
        
        self.columns = columns
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: spacing){
            ForEach(columns) { column in
                LazyVStack(spacing: spacing){
                    ForEach(column.gridItems) { gridItem in
                        NavigationLink(destination: PageDetailView(page: gridItem.page,pageType: pageViewType)){
                            ZStack{
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(gridItem.color)
                                VStack{
                                    HStack{
                                        Text(gridItem.page.title).font(.custom("Poppins-Regular", size: 24)).multilineTextAlignment(.leading).foregroundColor(.black)
                                        Spacer()
                                    }.padding(.bottom,10)
                                        .frame(minWidth: 0, maxWidth: .infinity,alignment: .leading)
                                    WrappingHStack(gridItem.page.tags, lineSpacing:4) { model in
                                      Text(model)
                                            .padding(5)
                                            .font(.body)
                                            .background(Color.blue)
                                            .foregroundColor(Color.white)
                                            .cornerRadius(5)
                                    }.padding(.bottom,10)
                                        .frame(minWidth: 0, maxWidth: .infinity,alignment: .leading)
                                    HStack{
                                        Text(gridItem.page.timeStamp).font(.custom("Poppins-Thin", size: 18)).multilineTextAlignment(.leading).foregroundColor(.black)
                                        Spacer()
                                    }.frame(minWidth: 0, maxWidth: .infinity,alignment: .leading)
                                }.frame(minWidth: 0, maxWidth: .infinity).padding()
                            }
                        }
                    }
                }
            }
        }.padding(.horizontal,horizontalPadding)
    }
}

struct DynamicHeightGrid_Previews: PreviewProvider {
    static var previews: some View {
        DynamicHeightGrid(gridItems: [], numOfColumns: 3,pageViewType: PageViewType.mainView)
    }
}
