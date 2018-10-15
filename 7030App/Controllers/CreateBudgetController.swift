//
//  ViewController.swift
//  7030App
//

import UIKit
import Firebase
import FontAwesome_swift

class CreateBudgetController: UIViewController, UpdateBudgetTypeDelegate, AddBalanceDelegate {

    @IBOutlet weak var imgStartingBalance: UIImageView!
    @IBOutlet weak var imgSavingBudget: UIImageView!
    @IBOutlet weak var imgExpenseBudget: UIImageView!
    
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBOutlet weak var infoTextView: UITextView!
    
    var currentTemplate: Template?;
    
    var startingBalance: Double?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        self.imgSavingBudget.image = UIImage.fontAwesomeIcon(name: .checkCircle, style: .regular, textColor: .white, size: CGSize(width: 40, height: 40))
        self.imgStartingBalance.image = UIImage.fontAwesomeIcon(name: .checkCircle, style: .regular, textColor: .white, size: CGSize(width: 40, height: 40))
        self.imgExpenseBudget.image = UIImage.fontAwesomeIcon(name: .checkCircle, style: .regular, textColor: .white, size: CGSize(width: 40, height: 40))
        self.btnContinue.center.x = self.view.center.x  
        self.infoTextView.center.x = self.view.center.x
        
        if (self.currentTemplate?.expenses.categories.count)! > 0{
            self.imgSavingBudget.image = UIImage.fontAwesomeIcon(name: .checkCircle, style: .regular, textColor: .green, size: CGSize(width: 40, height: 40))
            self.imgExpenseBudget.image = UIImage.fontAwesomeIcon(name: .checkCircle, style: .regular, textColor: .green, size: CGSize(width: 40, height: 40))
            self.imgStartingBalance.image = UIImage.fontAwesomeIcon(name: .checkCircle, style: .regular, textColor: .green, size: CGSize(width: 40, height: 40))
            
            var sum: Double = 0;
            for cat in self.currentTemplate!.expenses.categories {
                sum += cat.amount!
            }
            for cat in self.currentTemplate!.savings.categories {
                sum += cat.amount!
            }
            self.startingBalance = sum;
            self.btnContinue.isHidden = false;
        }
        
    }
    
    func onAddBalance(balance: Double) {
        self.startingBalance = balance;
        if (self.startingBalance != nil && (self.currentTemplate?.savings.categories.count)! >= 1
            && (self.currentTemplate?.expenses.categories.count)! >= 1) {
            self.btnContinue.isHidden = false;
        }
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        if (self.startingBalance != nil && (self.currentTemplate?.savings.categories.count)! >= 1
            && (self.currentTemplate?.expenses.categories.count)! >= 1) {
            self.performSegue(withIdentifier: "unwindToTemplates", sender: sender)
        }
    }
    
    @IBAction func startingBalancePressed(_ sender: Any) {
        self.performSegue(withIdentifier: "addBalanceSegue", sender: sender)
        self.imgStartingBalance.image = UIImage.fontAwesomeIcon(name: .checkCircle, style: .regular, textColor: .green, size: CGSize(width: 40, height: 40))
    }
    
    @IBAction func savingsBudgetPressed(_ sender: Any) {
        if (self.startingBalance != nil) {
            self.performSegue(withIdentifier: "setSavingBudgetSegue", sender: sender)
        }
    }
    
    @IBAction func expenseBudgetPressed(_ sender: Any) {
        if (self.startingBalance != nil) {
            self.performSegue(withIdentifier: "setExpenseBudgetSegue", sender: sender)
        }
    }
    
    func onBudgetTypeUpdate(budgetTypeName: String, budgetType: BudgetType) {
        if (budgetTypeName == "Secondary") {
            self.currentTemplate?.savings = budgetType
            self.imgSavingBudget.image = UIImage.fontAwesomeIcon(name: .checkCircle, style: .regular, textColor: .green, size: CGSize(width: 40, height: 40))
        } else {
            self.currentTemplate?.expenses = budgetType
            self.imgExpenseBudget.image = UIImage.fontAwesomeIcon(name: .checkCircle, style: .regular, textColor: .green, size: CGSize(width: 40, height: 40))
        }
        if (self.startingBalance != nil && (self.currentTemplate?.savings.categories.count)! >= 1
            && (self.currentTemplate?.expenses.categories.count)! >= 1) {
            self.btnContinue.isHidden = false;
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "setSavingBudgetSegue") {
            let controller = (segue.destination as! SetBudgetController)
            controller.sectionName = "Secondary"
            controller.budgetType = self.currentTemplate?.savings;
            controller.delegate = self
            controller.amount = Float(self.startingBalance! * (self.currentTemplate!.savings.percentage / 100))
            controller.budgetTypeText = "Secondary Budgets"
        } else if(segue.identifier == "setExpenseBudgetSegue") {
            let controller = (segue.destination as! SetBudgetController)
            controller.sectionName = "Primary"
            controller.budgetType = self.currentTemplate?.expenses;
            controller.delegate = self
            controller.budgetTypeText = "Primary Budgets"
            controller.amount = Float(self.startingBalance! * (self.currentTemplate!.expenses.percentage / 100))
        } else if(segue.identifier == "addBalanceSegue") {
            let controller = (segue.destination as! StartingBalanceController)
            controller.startingBalance = self.startingBalance
            controller.delegate = self
        } else if(segue.identifier == "unwindToTemplates") {
            let controller = (segue.destination as! TemplatesTableViewController)
            let found = controller.allTemplates.firstIndex(where: { $0.name == self.currentTemplate!.name }) ?? -1;
            
            if found >= 0 {
                controller.allTemplates[found] = self.currentTemplate!
            } else {
                controller.allTemplates.append(self.currentTemplate!)
            }
            controller.currentTemplate = self.currentTemplate
            controller.needUpdate = true
            controller.currentUser.currentTemplate = self.currentTemplate?.name
        }
    }
}
