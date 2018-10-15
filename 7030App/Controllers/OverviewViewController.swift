//
//  OverviewViewController.swift
//  7030App
//
//  Created by Khyteang on 8/19/18.
//  Copyright © 2018 Khyteang. All rights reserved.
//

import UIKit
import Firebase
import FontAwesome_swift
import PopupDialog

class OverviewViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var currentUser: UserModel!
    var currentTemplate: Template!
    var dataNeedsUpdate: Bool = false
    
    var allTemplates: [Template]!;
 
    @IBOutlet weak var templatesButton: UIButton!
    @IBOutlet weak var expenseCategories: UICollectionView!
    @IBOutlet weak var savingsCategories: UICollectionView!
    
    @IBOutlet weak var btnExpenseChart: UIButton!
    @IBOutlet weak var btnSavingChart: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(OverviewViewController.onFinish), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OverviewViewController.onFinish), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        self.expenseCategories.delegate = self
        self.savingsCategories.delegate = self
        self.expenseCategories.dataSource = self
        self.savingsCategories.dataSource = self
        
        if (allTemplates != nil && allTemplates.count > 0) {
            self.templatesButton.isEnabled = true
            self.btnSavingChart.isEnabled = true
            self.btnExpenseChart.isEnabled = true
        }
    }
    
    @IBAction func templatePressed(_ sender: Any) {
        self.performSegue(withIdentifier: "templatesSegue", sender: nil)
    }
    
    @IBAction func expenseChartClick(_ sender: Any) {
        self.performSegue(withIdentifier: "expenseChartSegue", sender: sender)
    }
    
    
    @IBAction func savingsChartClick(_ sender: Any) {
        self.performSegue(withIdentifier: "savingChartSegue", sender: sender)
    }
    
    
    @IBAction func unwindFromTemplatesTableToOverview(_ sender: UIStoryboardSegue) {
        if (allTemplates != nil && allTemplates.count > 0) {
            self.templatesButton.isEnabled = true
            self.btnSavingChart.isEnabled = true
            self.btnExpenseChart.isEnabled = true
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (currentTemplate == nil) {
            return 0;
        }
        
        if (collectionView == self.expenseCategories) {
            return currentTemplate.expenses.categories.count
        }
        return currentTemplate.savings.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == self.expenseCategories) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OverviewItemCell", for: indexPath) as! OverviewItemCell
            cell.lblHeader.text = self.currentTemplate.expenses.categories[indexPath.row].name
            let iconName = self.currentTemplate.expenses.categories[indexPath.row].iconName
            cell.imageIcon.image = UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesomeIcons[iconName]!)!, style: .solid, textColor: .white, size: CGSize(width: 40, height: 40))
            let amount = self.currentTemplate.expenses.categories[indexPath.row].amount
            cell.lblRemaining.text = String(format: "$%.02f", Double(amount!));
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OverviewItemCell", for: indexPath) as! OverviewItemCell
            cell.lblHeader.text = self.currentTemplate.savings.categories[indexPath.row].name
            let iconName = self.currentTemplate.savings.categories[indexPath.row].iconName
            cell.imageIcon.image = UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesomeIcons[iconName]!)!, style: .solid, textColor: .white, size: CGSize(width: 40, height: 40))
            let amount = self.currentTemplate.savings.categories[indexPath.row].amount
            cell.lblRemaining.text = String(format: "$%.02f", Double(amount!));
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "templatesSegue") {
            let controller = (segue.destination as! TemplatesTableViewController)
            controller.allTemplates = self.allTemplates;
            controller.currentUser = self.currentUser;
            controller.currentTemplate = self.currentTemplate;
        } else if(segue.identifier == "emptyCreateTemplateSegue") {
            let controller = (segue.destination as! TemplatesTableViewController)
            controller.allTemplates = [];
            controller.currentUser = self.currentUser;
        } else if(segue.identifier == "expenseChartSegue") {
            let controller = (segue.destination as! ChartsController)
            controller.budgetType = self.currentTemplate.expenses
            controller.chartTitle = "Primary categories remaining"
        } else if(segue.identifier == "savingChartSegue") {
            let controller = (segue.destination as! ChartsController)
            controller.budgetType = self.currentTemplate.savings
            controller.chartTitle = "Secondary categories remaining"
        }
    }
    
    func afterLoadUserFromDB(user: UserModel) {
        self.currentUser = user
        if (self.currentUser.currentTemplate == nil) {
            self.performSegue(withIdentifier: "emptyCreateTemplateSegue", sender: "Overview View Controller")
        } else {
            let user = Auth.auth().currentUser
            Template.load(db: Firestore.firestore(), uid: user!.uid, templateName: self.currentUser!.currentTemplate!, onSuccess: { (_template: Template) in
                self.currentTemplate = _template
                self.expenseCategories.reloadData()
                self.savingsCategories.reloadData()
                Template.allTemplates(db: Firestore.firestore(), uid: self.currentUser!.uid!, onSuccess: { (templates: [Template]) in
                    self.allTemplates = templates;
                    self.templatesButton.isEnabled = true
                    self.btnSavingChart.isEnabled = true
                    self.btnExpenseChart.isEnabled = true
                }, onFailure: { (error: Error?) in
                    // There was an error loading the template....
                })
            }, onFailure: { (error: Error?) in
                // There was an error loading the template....
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == self.expenseCategories) {
            showCustomDialog(category: self.currentTemplate.expenses.categories[indexPath.row], budgetTypeName: "expenses")
        } else {
            showCustomDialog(category: self.currentTemplate.savings.categories[indexPath.row], budgetTypeName: "savings")
        }
    }
    
    func showCustomDialog(category: Category, budgetTypeName: String, animated: Bool = true) {
        
        // Create a custom view controller
        let addSubtractVC = AddSubtractTransaction(nibName: "AddSubtractTransaction", bundle: nil)
        
        // Create the dialog
        let popup = PopupDialog(viewController: addSubtractVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: true,
                                panGestureDismissal: false)
        
        // Create substrate button
        let subtractBtn = DestructiveButton(title: "Subtract") {
            let vc = popup.viewController as! AddSubtractTransaction;
            let text: String = vc.txtAmount.text == "" ? "0" : vc.txtAmount.text!;
            var budgetType = budgetTypeName == "expenses" ? self.currentTemplate!.expenses : self.currentTemplate!.savings;

            for var i in 0..<budgetType.categories.count {
                if (budgetType.categories[i].name == category.name) {
                    let current = budgetType.categories[i].amount!;
                    budgetType.categories[i].amount = current - Double(text)!
                    if budgetTypeName == "expenses"{
                        self.currentTemplate.expenses.categories[i] = budgetType.categories[i]
                    } else {
                        self.currentTemplate.savings.categories[i] = budgetType.categories[i]
                    }
                    self.dataNeedsUpdate = true;
                    self.expenseCategories.reloadData()
                    self.savingsCategories.reloadData()
                }
            }
        }
    
        // Create add button
        let addBtn = DefaultButton(title: "Add") {
            let vc = popup.viewController as! AddSubtractTransaction;
            let text: String = vc.txtAmount.text == "" ? "0" : vc.txtAmount.text!;
            var budgetType = budgetTypeName == "expenses" ? self.currentTemplate!.expenses : self.currentTemplate!.savings;
            
            for var i in 0..<budgetType.categories.count {
                if (budgetType.categories[i].name == category.name) {
                    let current = budgetType.categories[i].amount!;
                    budgetType.categories[i].amount = current + Double(text)!
                    if budgetTypeName == "expenses"{
                        self.currentTemplate.expenses.categories[i] = budgetType.categories[i]
                    } else {
                        self.currentTemplate.savings.categories[i] = budgetType.categories[i]
                    }
                    self.dataNeedsUpdate = true;
                    self.expenseCategories.reloadData()
                    self.savingsCategories.reloadData()
                }
            }
        }
        
        // Add buttons to dialog
        popup.addButtons([subtractBtn, addBtn])

        
        // Present dialog
        present(popup, animated: animated, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (self.currentTemplate == nil) {
            let user = Auth.auth().currentUser
            let db = Firestore.firestore()
            UserModel.load(db: db, uid: user!.uid, onSuccess: { (_user: UserModel) in
                self.afterLoadUserFromDB(user: _user)
            }, onFailure: { (error: Error?) in
                UserModel.init(name: (user?.email)!, uid: (user?.uid)!).save(db: db, onSuccess: { (_user: UserModel) in
                    self.afterLoadUserFromDB(user: _user)
                }, onFailure: { (error: Error?) in
                    print(error)
                    // Alert that it failed.
                })
            })
        }
    }
    
    func saveData() {
        if (dataNeedsUpdate) {
            self.currentTemplate.save(db: Firestore.firestore(), user: self.currentUser, onSuccess: { (_template: Template) in
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
    
    @IBAction func signOutBtnPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            saveData()
            self.performSegue(withIdentifier: "unwindToLoginSegue", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}
