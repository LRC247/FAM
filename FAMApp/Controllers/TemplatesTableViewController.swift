//
//  TemplatesTableViewController.swift
//  FAMApp
//
//  Created by Rohit Krishnan on 9/22/18.
//  Copyright © 2018 Khyteang. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TemplatesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var allTemplates: [Template]!;
    var currentUser: UserModel!;
    var currentTemplate: Template?;
    var needUpdate = false
    
    var currentlyEditingTemplate: Template?;
    
    @IBOutlet weak var table: UITableView!
    @IBAction func doneButton(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToOverview", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.table.delegate = self
        self.table.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        if (self.currentTemplate == nil) {
            self.performSegue(withIdentifier: "newTemplateSegue", sender: self)
        }
        
        if self.needUpdate {
            self.table.reloadData()
            //if there is only one template, set it as the default
            if (self.allTemplates.count == 1) {
                self.currentUser.currentTemplate = self.allTemplates[0].name
                self.currentTemplate = self.allTemplates[0]
                self.performSegue(withIdentifier: "unwindToOverview", sender: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(OverviewViewController.onFinish), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OverviewViewController.onFinish), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    @IBAction func unwindFromCreateBudgetsToTemplates(segue: UIStoryboardSegue) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allTemplates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "prototypeCell")

        if cell == nil
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "prototypeCell")
        }

        cell?.textLabel?.text = self.allTemplates[indexPath.row].name;
        if (self.allTemplates[indexPath.row].name == self.currentUser.currentTemplate) {
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0);
        } else {
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 16);
        }
        
        return cell!;
    }
    
    func contextEditAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal,
                                        title: "Edit") {
                                            (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                self.currentlyEditingTemplate = self.allTemplates[indexPath.row]
                self.performSegue(withIdentifier: "editTemplateSegue", sender: nil)
        }
        
        action.backgroundColor = UIColor.gray
        return action
    }
    
    func contextDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal,
                                        title: "Delete") {
                                            (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            if self.allTemplates.count > 1{
                                                var needsNewCurrentTemplate = false;
                                                if self.currentTemplate?.name == self.allTemplates[indexPath.row].name {
                                                    needsNewCurrentTemplate = true;
                                                }
                                                self.allTemplates.remove(at: indexPath.row)
                                                if needsNewCurrentTemplate {
                                                    self.currentTemplate = self.allTemplates[0]
                                                    self.currentUser.currentTemplate = self.currentTemplate?.name
                                                    self.needUpdate = true
                                                    self.performSegue(withIdentifier: "unwindToOverview", sender: nil)
                                                }
                                                self.table.reloadData()
                                            } else {
                                                let alert = UIAlertController(title: "Cannot Delete", message: "You can't remove the only template in your account", preferredStyle: UIAlertControllerStyle.alert)
                                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                                    switch action.style{
                                                    case .default:
                                                        alert.dismiss(animated: true, completion: nil)
                                                        
                                                    case .cancel:
                                                        print("cancel")
                                                        
                                                    case .destructive:
                                                        print("destructive")
                                                        
                                                        
                                                    }}))
                                                self.present(alert, animated: true, completion: nil)
                                            }
        }
        
        action.backgroundColor = UIColor.red
        return action
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = self.contextEditAction(forRowAtIndexPath: indexPath)
        let deleteAction = self.contextDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        return swipeConfig
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Set Template", message: "Would you like to set this as your current template?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .default, handler: { _ in
            self.currentUser.currentTemplate = self.allTemplates[indexPath.row].name;
            self.currentTemplate = self.allTemplates[indexPath.row];
            self.needUpdate = true
            self.performSegue(withIdentifier: "unwindToOverview", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "No action"), style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: {
                
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addNewClick(_ sender: Any) {
        self.performSegue(withIdentifier: "newTemplateSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "newTemplateSegue") {
            let controller = (segue.destination as! TemplateViewController)
            controller.currentUser = self.currentUser;
        } else if(segue.identifier == "unwindToOverview") {
            let controller = (segue.destination as! OverviewViewController)
            controller.currentUser = self.currentUser;
            controller.currentTemplate = self.currentTemplate;
            controller.allTemplates = self.allTemplates;
            controller.dataNeedsUpdate = self.needUpdate;
            if (self.needUpdate) {
                controller.expenseCategories.reloadData()
                controller.savingsCategories.reloadData()
            }
        } else if(segue.identifier == "editTemplateSegue") {
            let controller = (segue.destination as! TemplateViewController)
            controller.currentUser = self.currentUser;
            controller.currentTemplate = self.currentlyEditingTemplate
        }
    }
    
    func saveData() {
        if (needUpdate) {
            self.currentTemplate!.save(db: Firestore.firestore(), user: self.currentUser, onSuccess: { (_template: Template) in
                print("DONE")
            }, onFailure:  { (error: Error?) in
                print("FAIL")
            });
            self.currentUser.save(db: Firestore.firestore(), onSuccess: { (_user: UserModel) in
                print("DONE")
            }, onFailure:  { (error: Error?) in
                print("FAIL")
            });
        }
    }
    
    @objc func onFinish() {
        saveData()
    }
    
}
