//
//  PageView.swift
//  roughpages
//
//  Created by Pranjal Chaudhari on 04/05/23.
//

import SwiftUI

enum PageViewType {
    case mainView
    case privateView
    case favoriteView
    case sharedView
    case collaborationView
}

struct PageView: View {
    let iAD = InAppDetails.inAppDetails
    let db = FirebaseController.firebaseController.firestore
    @State private var searchText = ""
    @State var pages: [PageModel] = []
    @State var favs: [String] = []
    let pagetype:PageViewType
    let displayMode: NavigationBarItem.TitleDisplayMode
    let navigationTitle: String
    @State var update = false
    @State var setPages: Set<PageModel> = []
    @State var filteredPages: [PageModel] = []
    
    let colors: [Color] = [Color("note_orange"),Color("note_red"),Color("note_green"),Color("note_blue"),Color("note_purple")]
    var body: some View {
        var gridItems = [GridItem]()
        var index = 0
        for page in filteredPages {
            let randomHeight = CGFloat.random(in: 100 ... 400)
            gridItems.append(GridItem(height: randomHeight, page: page, color: colors[index%5]))
            index += 1
        }
        return NavigationView{
            ZStack{
                ScrollView(.vertical,showsIndicators: false){
                    DynamicHeightGrid(gridItems: gridItems, numOfColumns: 2,pageViewType: pagetype ,spacing: 20, horizontalpadding: 20).frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity,alignment: .top)
                }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity,alignment: .top)
                if pagetype == .mainView {
                    ZStack(alignment: .bottomTrailing){
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                NavigationLink(destination: AddPageView(update:$update,page: PageModel(uid: iAD.uid, email: iAD.email, username: iAD.userName, description: "", title: "", tags: [], timeStamp: "", isPrivate: false, collaborators: [iAD.email], sharedWith: [], favorites: [], docId: "", path: ""), editType: .newPage)){
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .padding()
                                    .background(Color("brown"))
                                    .cornerRadius(25)
                                    .padding()
                                    .shadow(color: Color.black.opacity(0.3),
                                            radius: 3,
                                            x: 3,
                                            y: 3)
                                }
                                
                            }
                        }
                    }
                }
                
            }.navigationViewStyle(StackNavigationViewStyle())
                .navigationTitle(Text(navigationTitle))
                .navigationBarTitleDisplayMode(displayMode)
                //.navigationBarHidden(true)
                .onChange(of: searchText){ _ in
                    getFilteredPages()
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer)
        }.onAppear{
            getData()
        }
    }
    
    func getFilteredPages() {
        if searchText.isEmpty {
            filteredPages = pages
        }else{
            filteredPages = pages.filter{
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        //pages = pages.filter({$0.title.lowercased().contains(searchText.lowercased())})
    }
    
    func getData() {
        switch pagetype {
        case .mainView:
            print("Main appear")
            db.collection("Pages")
                .order(by: "docId", descending: true).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    guard let documents = querySnapshot?.documents else {
                        print("No documents")
                        return
                    }
                    pages = documents.map { (queryDocumentSnapshot) -> PageModel in
                        let data = queryDocumentSnapshot.data()
                        let docId = queryDocumentSnapshot.documentID
                        let username = data["username"] as? String ?? ""
                        let email = data["email"] as? String ?? ""
                        let uid = data["uid"] as? String ?? ""
                        let title = data["title"] as? String ?? ""
                        let description = data["description"] as? String ?? ""
                        let timeStamp = data["timeStamp"] as? String ?? ""
                        let tags = data["tags"] as? [String] ?? []
                        let c = data["collaborators"] as? [String] ?? []
                        let collaborators = Set(c)
                        let s = data["sharedWith"] as? [String] ?? []
                        let sharedWith = Set(s)
                        let isPrivtae = data["isPrivate"] as? Bool ?? false
                        let favorites = data["favorites"] as? [String] ?? []
                        let path = data["path"] as? String ?? ""
                        //iAD.uid = uid
                        //iAD.userName = username
                        //iAD.email = email
                        //print("got collabs: \(c)")
                        return PageModel(uid: uid, email: email, username: username, description: description, title: title, tags: tags, timeStamp: timeStamp, isPrivate: isPrivtae, collaborators: collaborators,sharedWith: sharedWith,favorites: favorites,docId: docId,path: path)
                    }
                    filteredPages = pages
                }
            }
        case .privateView:
            print("Private appear")
            db.collection("Users").document(iAD.uid).collection("private").order(by: "docId", descending: true).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    guard let documents = querySnapshot?.documents else {
                        print("No documents")
                        return
                    }
                    pages = documents.map { (queryDocumentSnapshot) -> PageModel in
                        let data = queryDocumentSnapshot.data()
                        let docId = queryDocumentSnapshot.documentID
                        let username = data["username"] as? String ?? ""
                        let email = data["email"] as? String ?? ""
                        let uid = data["uid"] as? String ?? ""
                        let title = data["title"] as? String ?? ""
                        let description = data["description"] as? String ?? ""
                        let timeStamp = data["timeStamp"] as? String ?? ""
                        let tags = data["tags"] as? [String] ?? []
                        let c = data["collaborators"] as? [String] ?? []
                        let collaborators = Set(c)
                        let s = data["sharedWith"] as? [String] ?? []
                        let sharedWith = Set(s)
                        let isPrivtae = data["isPrivate"] as? Bool ?? false
                        let favorites = data["favorites"] as? [String] ?? []
                        let path = data["path"] as? String ?? ""
                        //iAD.uid = uid
                        //iAD.userName = username
                        //iAD.email = email
                        return PageModel(uid: uid, email: email, username: username, description: description, title: title, tags: tags, timeStamp: timeStamp, isPrivate: isPrivtae, collaborators: collaborators,sharedWith: sharedWith,favorites: favorites,docId: docId,path: path)
                    }
                    filteredPages = pages
                }
            }
        case .favoriteView:
            print("fav appear")
            db.collection("Users").document(iAD.uid).getDocument{(document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    //print("Document data: \(dataDescription)")
                    if let data = document.data() {
                       //print("data", data)
                        let favs = document["favorites"] as? [String] ?? []
                        for fav in favs{
                            print(fav)
                            let pathFinder = fav.components(separatedBy: "/")
                            if pathFinder.count == 2 {
                                print("get public fav")
                                db.collection(pathFinder[0]).document(pathFinder[1]).getDocument{
                                    (document, error) in
                                    if let document = document, document.exists {
                                        if let data = document.data(){
                                            let docId = data["docId"] as? String ?? ""
                                            let username = data["username"] as? String ?? ""
                                            let email = data["email"] as? String ?? ""
                                            let uid = data["uid"] as? String ?? ""
                                            let title = data["title"] as? String ?? ""
                                            let description = data["description"] as? String ?? ""
                                            let timeStamp = data["timeStamp"] as? String ?? ""
                                            let tags = data["tags"] as? [String] ?? []
                                            let c = data["collaborators"] as? [String] ?? []
                                            let collaborators = Set(c)
                                            let s = data["sharedWith"] as? [String] ?? []
                                            let sharedWith = Set(s)
                                            let isPrivtae = data["isPrivate"] as? Bool ?? false
                                            let favorites = data["favorites"] as? [String] ?? []
                                            let path = data["path"] as? String ?? ""
                                            let pm = PageModel(uid: uid, email: email, username: username, description: description, title: title, tags: tags, timeStamp: timeStamp, isPrivate: isPrivtae, collaborators: collaborators,sharedWith: sharedWith,favorites: favorites,docId: docId,path: path)
                                            print("pm: \(pm)")
                                            setPages.insert(pm)
                                            pages = Array(setPages)
                                            filteredPages = pages
                                            //pages.append(Array(setPages))
                                        }
                                    }
                                }
                                
                            }else if pathFinder.count == 4 {
                                print("get private fav")
                                db.collection(pathFinder[0]).document(pathFinder[1]).collection(pathFinder[2]).document(pathFinder[3]).getDocument{
                                    (document, error) in
                                    if let document = document, document.exists {
                                        if let data = document.data(){
                                            let docId = data["docId"] as? String ?? ""
                                            let username = data["username"] as? String ?? ""
                                            let email = data["email"] as? String ?? ""
                                            let uid = data["uid"] as? String ?? ""
                                            let title = data["title"] as? String ?? ""
                                            let description = data["description"] as? String ?? ""
                                            let timeStamp = data["timeStamp"] as? String ?? ""
                                            let tags = data["tags"] as? [String] ?? []
                                            let c = data["collaborators"] as? [String] ?? []
                                            let collaborators = Set(c)
                                            let s = data["sharedWith"] as? [String] ?? []
                                            let sharedWith = Set(s)
                                            let isPrivtae = data["isPrivate"] as? Bool ?? false
                                            let favorites = data["favorites"] as? [String] ?? []
                                            let path = data["path"] as? String ?? ""
                                            let pm = PageModel(uid: uid, email: email, username: username, description: description, title: title, tags: tags, timeStamp: timeStamp, isPrivate: isPrivtae, collaborators: collaborators,sharedWith: sharedWith,favorites: favorites,docId: docId,path: path)
                                            print("pm: \(pm)")
                                            setPages.insert(pm)
                                            pages = Array(setPages)
                                            filteredPages = pages
                                            //pages.append(Array(setPages))
                                        }
                                    }
                                }
                            }
                            //print(pages)
                            
                        }
                        
                   }
                } else {
                    print("Document does not exist")
                }
            }
            
        case .sharedView:
            print("share appear")
            print("fav appear")
            db.collection("Users").document(iAD.uid).getDocument{(document, error) in
                if let document = document, document.exists {
                    if document.data() != nil {
                       //print("data", data)
                        let favs = document["sharedWithMe"] as? [String] ?? []
                        for fav in favs{
                            print(fav)
                            let pathFinder = fav.components(separatedBy: "/")
                            if pathFinder.count == 2 {
                                db.collection(pathFinder[0]).document(pathFinder[1]).getDocument{
                                    (document, error) in
                                    if let document = document, document.exists {
                                        if let data = document.data(){
                                            let docId = data["docId"] as? String ?? ""
                                            let username = data["username"] as? String ?? ""
                                            let email = data["email"] as? String ?? ""
                                            let uid = data["uid"] as? String ?? ""
                                            let title = data["title"] as? String ?? ""
                                            let description = data["description"] as? String ?? ""
                                            let timeStamp = data["timeStamp"] as? String ?? ""
                                            let tags = data["tags"] as? [String] ?? []
                                            let c = data["collaborators"] as? [String] ?? []
                                            let collaborators = Set(c)
                                            let s = data["sharedWith"] as? [String] ?? []
                                            let sharedWith = Set(s)
                                            let isPrivtae = data["isPrivate"] as? Bool ?? false
                                            let favorites = data["favorites"] as? [String] ?? []
                                            let path = data["path"] as? String ?? ""
                                            let pm = PageModel(uid: uid, email: email, username: username, description: description, title: title, tags: tags, timeStamp: timeStamp, isPrivate: isPrivtae, collaborators: collaborators,sharedWith: sharedWith,favorites: favorites,docId: docId,path: path)
                                            print("pm: \(pm)")
                                            setPages.insert(pm)
                                            pages = Array(setPages)
                                            filteredPages = pages
                                            //pages.append(Array(setPages))
                                        }
                                    }
                                }
                                
                            }else if pathFinder.count == 4 {
                                db.collection(pathFinder[0]).document(pathFinder[1]).collection(pathFinder[2]).document(pathFinder[3]).getDocument{
                                    (document, error) in
                                    if let document = document, document.exists {
                                        if let data = document.data(){
                                            let docId = data["docId"] as? String ?? ""
                                            let username = data["username"] as? String ?? ""
                                            let email = data["email"] as? String ?? ""
                                            let uid = data["uid"] as? String ?? ""
                                            let title = data["title"] as? String ?? ""
                                            let description = data["description"] as? String ?? ""
                                            let timeStamp = data["timeStamp"] as? String ?? ""
                                            let tags = data["tags"] as? [String] ?? []
                                            let c = data["collaborators"] as? [String] ?? []
                                            let collaborators = Set(c)
                                            let s = data["sharedWith"] as? [String] ?? []
                                            let sharedWith = Set(s)
                                            let isPrivtae = data["isPrivate"] as? Bool ?? false
                                            let favorites = data["favorites"] as? [String] ?? []
                                            let path = data["path"] as? String ?? ""
                                            let pm = PageModel(uid: uid, email: email, username: username, description: description, title: title, tags: tags, timeStamp: timeStamp, isPrivate: isPrivtae, collaborators: collaborators,sharedWith: sharedWith,favorites: favorites,docId: docId,path: path)
                                            print("pm: \(pm)")
                                            setPages.insert(pm)
                                            pages = Array(setPages)
                                            filteredPages = pages
                                            //pages.append(Array(setPages))
                                        }
                                    }
                                }
                            }
                            //print(pages)
                            
                        }
                        
                   }
                } else {
                    print("Document does not exist")
                }
            }
        case .collaborationView:
            print("collborations appear")
            db.collection("Users").document(iAD.uid).getDocument{(document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    //print("Document data: \(dataDescription)")
                    if let data = document.data() {
                       //print("data", data)
                        let favs = document["collaborations"] as? [String] ?? []
                        for fav in favs{
                            print(fav)
                            let pathFinder = fav.components(separatedBy: "/")
                            if pathFinder.count == 2 {
                                db.collection(pathFinder[0]).document(pathFinder[1]).getDocument{
                                    (document, error) in
                                    if let document = document, document.exists {
                                        if let data = document.data(){
                                            let docId = data["docId"] as? String ?? ""
                                            let username = data["username"] as? String ?? ""
                                            let email = data["email"] as? String ?? ""
                                            let uid = data["uid"] as? String ?? ""
                                            let title = data["title"] as? String ?? ""
                                            let description = data["description"] as? String ?? ""
                                            let timeStamp = data["timeStamp"] as? String ?? ""
                                            let tags = data["tags"] as? [String] ?? []
                                            let c = data["collaborators"] as? [String] ?? []
                                            let collaborators = Set(c)
                                            let s = data["sharedWith"] as? [String] ?? []
                                            let sharedWith = Set(s)
                                            let isPrivtae = data["isPrivate"] as? Bool ?? false
                                            let favorites = data["favorites"] as? [String] ?? []
                                            let path = data["path"] as? String ?? ""
                                            let pm = PageModel(uid: uid, email: email, username: username, description: description, title: title, tags: tags, timeStamp: timeStamp, isPrivate: isPrivtae, collaborators: collaborators,sharedWith: sharedWith,favorites: favorites,docId: docId,path: path)
                                            print("pm: \(pm)")
                                            setPages.insert(pm)
                                            pages = Array(setPages)
                                            filteredPages = pages
                                            //pages.append(Array(setPages))
                                        }
                                    }
                                }
                                
                            }else if pathFinder.count == 4 {
                                db.collection(pathFinder[0]).document(pathFinder[1]).collection(pathFinder[2]).document(pathFinder[3]).getDocument{
                                    (document, error) in
                                    if let document = document, document.exists {
                                        if let data = document.data(){
                                            let docId = data["docId"] as? String ?? ""
                                            let username = data["username"] as? String ?? ""
                                            let email = data["email"] as? String ?? ""
                                            let uid = data["uid"] as? String ?? ""
                                            let title = data["title"] as? String ?? ""
                                            let description = data["description"] as? String ?? ""
                                            let timeStamp = data["timeStamp"] as? String ?? ""
                                            let tags = data["tags"] as? [String] ?? []
                                            let c = data["collaborators"] as? [String] ?? []
                                            let collaborators = Set(c)
                                            let s = data["sharedWith"] as? [String] ?? []
                                            let sharedWith = Set(s)
                                            let isPrivtae = data["isPrivate"] as? Bool ?? false
                                            let favorites = data["favorites"] as? [String] ?? []
                                            let path = data["path"] as? String ?? ""
                                            let pm = PageModel(uid: uid, email: email, username: username, description: description, title: title, tags: tags, timeStamp: timeStamp, isPrivate: isPrivtae, collaborators: collaborators,sharedWith: sharedWith,favorites: favorites,docId: docId,path: path)
                                            print("pm: \(pm)")
                                            setPages.insert(pm)
                                            pages = Array(setPages)
                                            filteredPages = pages
                                            //pages.append(Array(setPages))
                                        }
                                    }
                                }
                            }
                            //print(pages)
                            
                        }
                        
                   }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(pagetype: PageViewType.mainView,displayMode: .automatic,navigationTitle: "Pages")
    }
}
