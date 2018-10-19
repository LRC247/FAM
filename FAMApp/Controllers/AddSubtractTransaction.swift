import UIKit

class AddSubtractTransaction: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var txtAmount: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtAmount.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String)
        -> Bool {
            switch string {
            case "0","1","2","3","4","5","6","7","8","9":
                return true
            case ".":
                let array = Array(textField.text!)
                var decimalCount = 0
                for character in array {
                    if character == "." {
                        decimalCount+=1
                    }
                }
                
                if decimalCount == 1 {
                    return false
                } else {
                    return true
                }
            default:
                let array = Array(string)
                if array.count == 0 {
                    return true
                }
                return false
            }
    }
    
}
