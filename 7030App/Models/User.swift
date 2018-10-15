//
//  User.swift
//  7030App
//
//  Created by Khyteang on 8/21/18.
//  Copyright © 2018 Khyteang. All rights reserved.
//
import Firebase
import CodableFirebase

struct UserModel: Codable {
    var uid: String?
    var name: String?
    var currentTemplate: String?
    
    init(name: String, uid: String) {
        self.name = name
        self.uid = nil
        self.currentTemplate = nil
    }
    
    static func load(db: Firestore, uid: String, onSuccess success: @escaping (_ user: UserModel) -> Void, onFailure failure: @escaping (_ error: Error?) -> ()) {
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document {
                let data = document.data()
                if (data != nil) {
                    let model = try! FirestoreDecoder().decode(UserModel.self, from: data!)
                    success(model);
                } else {
                    failure(nil);
                }
            } else {
                failure(nil);
            }
        }
    }
    
    
    func save(db: Firestore, onSuccess success: @escaping (_ user: UserModel) -> Void, onFailure failure: @escaping (_ error: Error?) -> ()) {
        var docData = try! FirestoreEncoder().encode(self)
    
        var uid = self.uid
        if (uid == nil) {
            let user = Auth.auth().currentUser
            uid = user?.uid
            if (user?.displayName != nil) {
                docData["name"] = user?.displayName
            } else {
                docData["name"] = ""
            }
            
            docData["uid"] = uid
        }
        
        db.collection("users").document(uid!).setData(docData) { error in
            if let error = error {
                failure(error);
            } else {
                UserModel.load(db: db, uid: uid!, onSuccess: { (_user: UserModel) in
                    success(_user);
                }, onFailure: { (error: Error?) in
                    failure(error);
                })
            }
        }
    }
}
