//
//  MainAppView.swift
//  roughpages
//
//  Created by Harvinder Laliya on 03/05/23.
//

import SwiftUI

struct MainAppView: View {
    
    var body: some View {
        return NavigationStack{
            TabView{
                PageView(pagetype: PageViewType.mainView, displayMode: .automatic, navigationTitle: "Pages").tabItem{
                    Label("Pages",systemImage: "flame.fill")
                }
                ProfileView().tabItem{
                    Label("Profile",systemImage: "person.fill")
                }
            }
            
        }.navigationViewStyle(StackNavigationViewStyle())
        .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity,alignment: .top)
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}
