//
//  ViewController.swift
//  FAMApp
//

import UIKit
import Firebase
import PopupDialog

class SetBudgetController: UIViewController, UpdateCategoryDelegate {
    
    var delegate: UpdateBudgetTypeDelegate!;
    var budgetType: BudgetType!
    var amount: Float!;
    
    var budgetTypeText = ""
    
    var chosenCategoryForEdit: Category?;
    var sectionName = ""
    var currentTemplate: Template?
    var categoryCount = 0
    var allTemplates: [Template]!;
    
    @IBOutlet weak var txtBudgetType: UILabel!
    @IBOutlet weak var txtPercentAmount: UILabel!
    
    func getSum() -> Double{
        var sum: Double = 0.0
        for cat in self.budgetType.categories {
            sum += cat.percentage
        }
        return sum;
    }
    
    func fixSum() {
        let sum = self.getSum()
        for i in 0...self.budgetType.categories.count - 1 {
            self.budgetType.categories[i].percentage -= round((sum - 100) / Double(self.budgetType.categories.count))
            let percentage = self.budgetType.categories[i].percentage / 100
            self.budgetType.categories[i].amount = Double(self.amount) * percentage
        }
        let newSum = self.getSum()
        if newSum != 100 {
            self.budgetType.categories[0].percentage += 100 - newSum
            self.budgetType.categories[0].amount = Double(self.amount) * (self.budgetType.categories[0].percentage / 100)
        }
    }
    
    @IBAction func btnSave(_ sender: Any) {
        let alertTitle = "Create Budget"
        var alertMessage = ""
        var alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let sum = self.getSum()
        
        if (categoryCount == 0) {
            alertMessage = "In order to create a budget for " + self.budgetTypeText + ", please add 1 or more category to the list."
            alertController.message = alertMessage
            
            alertController.addAction(UIAlertAction(title: "Will do", style: .default, handler: { _ in
                alertController.dismiss(animated: true, completion: {
                    
                })
            }))
            
            self.present(alertController, animated: true, completion: nil)
        } else if (sum != 100) {
            alertMessage = "Make sure all your categories add up to 100%. Tap 'fix' to have us do this for you."
            alertController.message = alertMessage
            
            alertController.addAction(UIAlertAction(title: "Go Back", style: .default, handler: { _ in
                alertController.dismiss(animated: true, completion: {
                    
                })
            }))
            
            alertController.addAction(UIAlertAction(title: "Fix for me", style: .default, handler: { _ in
                self.fixSum()
                self.budgetCategories.reloadData()
            }))
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.delegate.onBudgetTypeUpdate(budgetTypeName: self.sectionName, budgetType: self.budgetType)
            self.dismiss(animated: true, completion: nil)
        }
            
    }
    
    func onNewCategory(category: Category) {
        self.budgetType.categories.append(category)
        self.budgetCategories.reloadData()
    }
    
    func onEditCategory(category: Category) {
        for i in 0...(self.budgetType.categories.count - 1) {
            if (self.budgetType.categories[i].index == category.index) {
                self.budgetType.categories[i] = category
            }
        }
        self.budgetCategories.reloadData()
    }
    
    @IBOutlet weak var budgetCategories: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.budgetCategories.backgroundColor = UIColor.clear.withAlphaComponent(0)
        self.budgetCategories.dataSource = self
        self.budgetCategories.delegate = self
        self.categoryCount = self.budgetType.categories.count
        self.txtBudgetType.text = self.budgetTypeText
        self.txtPercentAmount.text = String(format: "%d%%", Int(round(self.budgetType.percentage)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addCategorySegue") {
            let controller = (segue.destination as! AddCategoryController)
            controller.currentCategory = nil;
            controller.delegate = self;
            controller.amount = self.amount
            controller.index = self.categoryCount
            self.categoryCount += 1
        } else if(segue.identifier == "editCategorySegue") {
            let controller = (segue.destination as! AddCategoryController)
            controller.currentCategory = self.chosenCategoryForEdit!
            controller.delegate = self;
            controller.amount = self.amount
        }
    }
}

protocol UpdateBudgetTypeDelegate {
    func onBudgetTypeUpdate(budgetTypeName: String, budgetType: BudgetType)
}
