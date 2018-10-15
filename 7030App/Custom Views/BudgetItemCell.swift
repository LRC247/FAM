import UIKit

@IBDesignable class BudgetItemCell: UICollectionViewCell {
    var view:UIView!
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblPercent: UILabel!
    
    var delegate: RemoveCategoryDelegate!
    
    @IBAction func btnRemove(_ sender: Any) {
        self.delegate.removeCat(name: self.lblHeader!.text!)
    }
    
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
        //        self.view = loadViewFromNib() as! CustomView
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
        
        self.layer.cornerRadius = 5
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of:self))
        let nib = UINib(nibName: "BudgetItemCell", bundle: bundle)
         
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}

protocol RemoveCategoryDelegate {
    func removeCat(name: String)
}
