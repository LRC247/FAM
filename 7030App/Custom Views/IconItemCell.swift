import UIKit

@IBDesignable class IconItemCell: UICollectionViewCell {
    var view:UIView!
    
    
    @IBOutlet weak var iconImage: UIImageView!
    
    var iconName: String!
    
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
        let nib = UINib(nibName: "IconItemCell", bundle: bundle)
         
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    func select() {
        view.backgroundColor = UIColor(red:0.39, green:0.47, blue:0.55, alpha:1.0)
        self.isSelected = true
    }
    
    func deselect() {
        view.backgroundColor = UIColor(red:0.39, green:0.75, blue:0.55, alpha:1.0)
        self.isSelected = false
    }
}
