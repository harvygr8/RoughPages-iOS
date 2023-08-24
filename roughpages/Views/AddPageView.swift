//
//  AddPageView.swift
//  roughpages
//
//  Created by Harvinder Laliya on 03/05/23.
//

import SwiftUI
import MarkdownUI
import WrappingHStack

enum TextFormatting {
    case bold
    case italic
    case underline
}

enum EditType {
    case newPage
    case editPage
}

struct AddPageView: View {
    @State private var titleText: String = ""
    @State private var description: String = ""
    let iAD = InAppDetails.inAppDetails
    let db = FirebaseController.firebaseController.firestore
    @State var showAddTagSheet = false
    @State var showShareSheet = false
    @State var showCollaboratorSheet = false
    @State var showFormatSheet = false
    @State var tags: [String] = []
    @Binding var update: Bool
    @Environment(\.dismiss) var dismiss
    @State private var text = ""
    @State private var selectedRange: NSRange = NSMakeRange(0, 0)
    @State private var selectedRange2: UITextRange?
    @State var didStartEditing = false
    @State private var isPrivate = false
    @State private var collaborators:Set<String> = []
    @State private var sharedWith:Set<String> = []
    @State private var publicToPrivate = false
    @State var viewType = 0
    let page: PageModel
    let editType: EditType
    
    var body: some View {
        VStack{
            Picker("Type", selection: $viewType) {
                Text("Editor").tag(0)
                Text("Preview").tag(1)
            }.pickerStyle(.segmented)
                .padding(.bottom)
            
            if viewType == 0 {
                editorView()
            } else {
                previewView()
            }
            
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity,alignment: .top)
            .padding()
            .navigationTitle(Text(editType == .newPage ? "Add new page" : "Edit page"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        if !description.isEmpty {
                            showFormatSheet = true
                        }
                    }){
                        Image(systemName: "textformat")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu {
                        Button(action: {
                            if !titleText.isEmpty {
                                showAddTagSheet = true
                            }
                        }){
                            Label("Add tags",systemImage: "tag")
                        }
                        Toggle(isOn: $isPrivate){
                            Text("Private")
                            Image(systemName: "eye")
                        }
                    }label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Saving page!")
                        print("title: \(titleText)")
                        print("description: \(description)")
                        if titleText.isEmpty || description.isEmpty {
                            return
                        }
                        let docId = NSDate().timeIntervalSince1970
                        let dateTime = Date()
                        let df = DateFormatter()
                        df.dateStyle = DateFormatter.Style.long
                        df.timeStyle = DateFormatter.Style.short
                        let date = df.string(from: dateTime)
                        print("Date: \(date)")
                        let documentID = editType == .newPage ? String(docId) : page.docId
                        var docRef = isPrivate ?
                        db.collection("Users").document(iAD.uid).collection("private").document(documentID):
                        db.collection("Pages").document(documentID)
                        var pathFinder:[String] = []
                        if editType == .editPage {
                            pathFinder = page.path.components(separatedBy: "/")
                            if pathFinder.count == 2 {
                                docRef = db.collection(pathFinder[0]).document(pathFinder[1])
                            }else if pathFinder.count == 4 {
                                docRef = db.collection(pathFinder[0]).document(pathFinder[1]).collection(pathFinder[2]).document(pathFinder[3])
                            }
                            
                        }
                        
                        
                        //Page link logic
                        var path = ""
                        if !isPrivate && editType == .newPage{
                            path = "Pages/\(documentID)"
                        }else if isPrivate && editType == .newPage{
                            path = "Users/\(iAD.uid)/private/\(documentID)"
                        }
                        
                        if !isPrivate && editType == .editPage {
                            path = "Pages/\(documentID)"
                        }else if isPrivate && editType == .editPage{
                            if pathFinder.count == 2{
                                print("public to private")
                                publicToPrivate = true
                                path = "Users/\(page.uid)/private/\(documentID)"
                                docRef = db.collection("Users").document(page.uid).collection("private").document(documentID)
                            }else {
                                path = "Users/\(pathFinder[1])/private/\(documentID)"
                            }
                        }
                        
                        
                        let data = [
                            "username":editType == .newPage ?  iAD.userName : page.username,
                            "email": editType == .newPage ? iAD.email : page.email,
                            "uid":editType == .newPage ? iAD.uid : page.uid,
                            "description": description,
                            "title": titleText,
                            "tags": tags,
                            "docId": documentID,
                            "timeStamp": date,
                            "collaborators": Array(collaborators),
                            "sharedWith": Array(sharedWith),
                            "isPrivate": isPrivate,
                            "path": path
                        ] as [String : Any]
                        
                        print(data)
                        print("final docRef: \(docRef.path)")
                        docRef.setData(data,merge: true){ error in
                            if let error = error {
                               print("Error updating document: \(error)")
                           } else {
                               print("Document successfully updated!")
                               if publicToPrivate {
                                   db.collection("Pages").document(documentID).delete{ err in
                                       if let err = err {
                                           print("Error removing document: \(err)")
                                       } else {
                                           print("Document successfully removed!")
                                       }
                                       //dismiss()
                                   }
                               }
                           }
                            if editType == .editPage{
                                update = true
                            }
                            dismiss()
                        }
                    }) {
                        Text("Save")
                    }.buttonStyle(.borderedProminent)
                }
            }
            .sheet(isPresented: $showAddTagSheet,onDismiss: {
                print("Tags: \(tags)")
            }){
                AddTag(tags: $tags)
            }
            .sheet(isPresented: $showFormatSheet){
                FormatSheetView(text: $description, selectedRange: $selectedRange)
            }.onAppear{
                collaborators.insert(iAD.email)
                if editType == .editPage {
                    print("pre load data")
                    titleText = page.title
                    description = page.description
                    isPrivate = page.isPrivate
                    collaborators = page.collaborators
                    sharedWith = page.sharedWith
                    tags = page.tags
                    didStartEditing = true
                }
            }
    }
    
    @ViewBuilder
    func editorView() -> some View{
        TextField("Title",text: $titleText,axis: .vertical).font(Font.custom("Poppins-Medium", size: 24)).onSubmit {
            print("title complete")
        }
        WrappingHStack(tags) { model in
          Text(model)
                .padding(.all, 5)
                .font(.body)
                .background(Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(5)
        }
        UITextViewRepresentable(text: $description, selectedRange: $selectedRange, didStartEditing: $didStartEditing).textSelection(.enabled)
            .onTapGesture {
                didStartEditing = true
            }
    }
    
    @ViewBuilder
    func previewView() -> some View {
        ScrollView{
            VStack{
                HStack{
                    Markdown{
                        Heading(.level1){
                            titleText
                        }
                    }
                }.frame(minWidth: 0,maxWidth: .infinity,alignment: .leading)
                
                WrappingHStack(tags) { model in
                  Text(model)
                        .padding(.all, 5)
                        .font(.body)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(5)
                }
                HStack{
                    Markdown(description)
                        .markdownTextStyle(\.code) {
                          FontFamilyVariant(.monospaced)
                          FontSize(.em(0.85))
                          ForegroundColor(.purple)
                          BackgroundColor(.purple.opacity(0.25))
                        }.markdownBlockStyle(\.blockquote) { configuration in
                            configuration.label
                              .padding()
                              .markdownTextStyle {
                                FontCapsVariant(.lowercaseSmallCaps)
                                FontWeight(.semibold)
                                BackgroundColor(nil)
                              }
                              .overlay(alignment: .leading) {
                                Rectangle()
                                  .fill(Color.teal)
                                  .frame(width: 4)
                              }
                              .background(Color.teal.opacity(0.5))
                          }
                }.frame(minWidth: 0,maxWidth: .infinity,alignment: .leading)
            }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity,alignment: .top)
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity,alignment: .top)
        
    }
}
