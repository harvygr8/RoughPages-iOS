//
//  PageModel.swift
//  roughpages
//
//  Created by Harvinder Laliya on 03/05/23.
//

import Foundation

struct PageModel: Codable, Hashable {
    var uid:String
    var email:String
    var username:String
    var description:String
    var title:String
    var tags: [String]
    var timeStamp: String
    var isPrivate: Bool
    var collaborators: Set<String>
    var sharedWith: Set<String>
    var favorites: [String]
    var docId: String
    var path: String
}
