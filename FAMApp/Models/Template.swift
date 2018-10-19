//
//  Template.swift
//  FAMApp
//
//  Created by Khyteang on 8/19/18.
//  Copyright © 2018 Khyteang. All rights reserved.
//
import CodableFirebase
import Firebase

struct Category: Codable {
    var name: String
    var amount: Double?
    var percentage: Double
    var iconName: String
    var index: Int
    
    init(name: String, amount: Double, percentage: Double, iconName: String, index: Int) {
        self.name = name
        self.amount = amount
        self.percentage = percentage
        self.iconName = iconName
        self.index = index
    }
}

struct BudgetType: Codable {
    var percentage: Double
    var categories: [Category]
    
    init(percentage: Double) {
        self.percentage = percentage
        self.categories = []
    }
}


struct Template: Codable {
    var name: String?
    var expenses: BudgetType
    var savings: BudgetType
    
    init(name: String, expenses: BudgetType, savings: BudgetType) {
        self.name = name
        self.expenses = expenses
        self.savings = savings
    }
    
    static func defaultTemplate() -> Template {
        let expenses = BudgetType(percentage: 70)
        let savings = BudgetType(percentage: 30)
        let template = Template.init(name: "", expenses: expenses, savings: savings)
        return template
    }
    
    static func load(db: Firestore, uid: String, templateName: String, onSuccess success: @escaping (_ user: Template) -> Void, onFailure failure: @escaping (_ error: Error?) -> ()) {
        db.collection("users/\(uid)/templates/").document(templateName).getDocument { document, error in
            if let document = document {
                var model = try! FirestoreDecoder().decode(Template.self, from: document.data()!)
                model.name = templateName;
                success(model);
            } else {
                failure(nil);
            }
        }
    }
    
    static func allTemplates(db: Firestore, uid: String, onSuccess success: @escaping (_ templates: [Template]) -> Void, onFailure failure: @escaping (_ error: Error?) -> ()) {
        db.collection("users/\(uid)/templates/").getDocuments { (querySnapshot, error) in
            var result: [Template] = [];
            for doc in querySnapshot!.documents {
                let model = try! FirestoreDecoder().decode(Template.self, from: doc.data())
                result.append(model)
            }
            success(result);
        }
    }
    
    func save(db: Firestore, user: UserModel, onSuccess success: @escaping (_ user: Template) -> Void, onFailure failure: @escaping (_ error: Error?) -> ()) {
        let uid = user.uid;
        
        if (user.uid == nil) {
            user.save(db: db, onSuccess: { (savedUser: UserModel) in
                self.save(db: db, user: savedUser, onSuccess: success, onFailure: failure)
            }) { (error: Error?) in
                failure(error);
            }
        } else {
            let docData = try! FirestoreEncoder().encode(self)
            db.collection("users/\(uid!)/templates/").document(self.name!).setData(docData) { error in
                if let error = error {
                    failure(error);
                } else {
                    success(self);
                }
            }
        }
    }
}
