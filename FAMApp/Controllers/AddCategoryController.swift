import UIKit
import Firebase
import FontAwesome_swift

class AddCategoryController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var sliderPercent: UISlider!
    
    @IBOutlet weak var lblPercent: UILabel!
    
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var iconCollectionView: UICollectionView!
    
    var selectedIconName: String?
    
    var currentCategory: Category?
    var delegate: UpdateCategoryDelegate!;
    var amount: Float!
    var index: Int = 0
    
    var iconsList = ["fa-amazon", "fa-anchor", "fa-cannabis", "fa-car-side", "fa-gas-pump", "fa-glass-martini-alt", "fa-graduation-cap",
                     "fa-golf-ball", "fa-hammer", "fa-gulp", "fa-horse", "fa-hotel", "fa-motorcycle", "fa-phone", "fa-plane departure",
                     "fa-money-bill-alt", "fa-piggy bank", "fa-home", "fa-warehouse", "fa-tv", "fa-helicopter", "fa-book", "fa-band-aid",
                     "fa-space shuttle", "fa-wine-bottle", "fa-umbrella", "fa-swimming pool", "fa-drafting", "fa-dumbbell", "fa-beer",
                     "fa-gift", "fa-fighter-jet", "fa-taxi", "fa-bus", "fa-train", "fa-globe-americas", "fa-credit-card",
                     "fa-shopping-cart", "fa-music", "fa-truck",
                     "fa-bus",
                     "fa-bicycle",
                     "fa-futbol",
                     "fa-car",
                     "fa-taxi",
                     "fa-book",
                     "fa-star",
                     "fa-train",
                     "fa-subway",
                     "fa-rocket",
                     "fa-calendar",
                     "fa-calendar-check",
                     "fa-amazon"]
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.txtName.resignFirstResponder()
        return true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        self.txtName.delegate = self
        if (self.currentCategory != nil) {
            self.txtName.text = self.currentCategory!.name
            self.sliderPercent.value = Float(((self.currentCategory?.percentage)!) / 100.00);
            self.lblPercent.text = "\(String(Int(100 * self.sliderPercent.value)))%";
        } else {

        }
        if (self.currentCategory != nil) {
            self.selectedIconName = self.currentCategory?.iconName
            self.iconCollectionView.reloadData()
        }
        
        self.iconCollectionView.dataSource = self
        self.iconCollectionView.delegate = self
    }
    
    @IBAction func sliderChange(_ sender: Any) {
        self.lblPercent.text = "\(String(format: "%.0f", Double(round(100 * self.sliderPercent!.value) / 100) * 100))%";
    }
    
    @IBAction func onSavePressed(_ sender: Any) {
        if (self.selectedIconName == nil) {
            return;
        }
        
        let roundedSliderPercentage = (round(100 * self.sliderPercent!.value) / 100)
        if (self.currentCategory == nil) {
            let category = Category.init(name: self.txtName.text!, amount: Double(self.amount * roundedSliderPercentage),
                                         percentage: Double(roundedSliderPercentage * 100),
                                         iconName: selectedIconName!,
                                         index: self.index)
            self.delegate?.onNewCategory(category: category)
        } else {
            self.currentCategory?.name = self.txtName.text!
            self.currentCategory?.amount = Double(self.amount * roundedSliderPercentage)
            self.currentCategory?.percentage = Double(roundedSliderPercentage * 100)
            self.currentCategory?.iconName = self.selectedIconName!
            self.delegate?.onEditCategory(category: self.currentCategory!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconItemCell", for: indexPath) as! IconItemCell
        var iconName: String;
        
        iconName = iconsList[indexPath.row]
        
        for i in 0...iconsList.count - 1 {
            if (FontAwesomeIcons[iconsList[i]] == nil) {
                    print(iconsList[i])
            }
        }
        
        cell.iconImage.image = UIImage.fontAwesomeIcon(name: FontAwesome(rawValue: FontAwesomeIcons[iconName]!)!, style: .solid, textColor: .white, size: CGSize(width: 40, height: 40))
        cell.iconName = iconName
        if (cell.iconName == self.selectedIconName) {
            cell.select()
        } else {
            cell.deselect()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell :IconItemCell = self.iconCollectionView.cellForItem(at: indexPath) as! IconItemCell
        self.selectedIconName = cell.iconName
        self.iconCollectionView.reloadData()
    }
}


protocol UpdateCategoryDelegate {
    func onNewCategory(category: Category)
    func onEditCategory(category: Category)
}
