//
//  Notes.swift
//  TaskCGTRealm
//
//  Created by mac on 17.03.2021.
//

import RealmSwift

class Notes: Object {
    
    @objc dynamic var note =  ""
    @objc dynamic var imageData: Data?
    
    convenience init(note: String, imageData: Data?) {
        self.init()
        self.note = note
        self.imageData = imageData
    }
}
