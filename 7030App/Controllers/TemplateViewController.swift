//
//  ViewController.swift
//  7030App
//

import UIKit
import Firebase

class TemplateViewController: UIViewController {
    
    var currentTemplate: Template?
    var currentUser: UserModel?
    
     @IBOutlet weak var templateName: UITextField!
    
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var percentSlider: UISlider!
    
    @IBOutlet weak var mainPercentTxt: UILabel!
    @IBOutlet weak var subPercentTxt: UILabel!
    
    @IBOutlet weak var headerText: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        if self.currentTemplate != nil{
            self.templateName.text = self.currentTemplate?.name
            self.headerText.text = "Edit Template"
            self.percentSlider.setValue(Float(((self.currentTemplate?.expenses.percentage)! / 100)), animated: true)
            let value = Int((round(100 * self.percentSlider.value) / 100) * 100)
            let secondValue = 100 - value
            self.mainPercentTxt.text = "\(value)%";
            self.subPercentTxt.text = "\(secondValue)%";
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let value = Int((round(100 * self.percentSlider.value) / 100) * 100)
        let secondValue = 100 - value
        self.mainPercentTxt.text = "\(value)%";
        self.subPercentTxt.text = "\(secondValue)%";
    }
    
    @IBAction func onContinueClick(_ sender: Any) {
        if (self.templateName.text! != "") {
            if self.currentTemplate?.expenses == nil {
                let template: Template = Template.defaultTemplate()
                self.currentTemplate = template;
            }
            self.currentTemplate!.name = self.templateName.text!
            
            let value:Double = Double((round(100 * self.percentSlider.value) / 100) * 100)
            self.currentTemplate!.expenses.percentage = value
            self.currentTemplate!.savings.percentage = 100 - value
            
            self.currentUser?.currentTemplate = self.currentTemplate!.name
            self.performSegue(withIdentifier: "createBudgetSegue", sender: sender)
        } else {
            self.templateName.layer.borderColor = UIColor.red.cgColor
            self.templateName.layer.borderWidth = 2
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "createBudgetSegue") {
            let controller = (segue.destination as! CreateBudgetController)
            controller.currentTemplate = self.currentTemplate
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.addTarget(self, action: #selector(backSegue) )
        swipeLeft.direction = .left
        self.view!.addGestureRecognizer(swipeLeft)
    }
    
    @IBAction func backSegue() {
        self.dismiss(animated: true) {
            
        }
    }
}
