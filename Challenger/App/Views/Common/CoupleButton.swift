import UIKit

protocol CoupleButtonDelegate {
    func buttonTapped(tag: Int)
}

class CoupleButton: UIView {
    @IBOutlet var view: UIView!

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var seperateView: UIView!
    
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    
    var delegate: CoupleButtonDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSBundle.mainBundle().loadNibNamed("CoupleButton", owner: self, options: nil)
        self.addSubview(view)
        
        backgroundView.layer.borderColor = Config.textFieldBorderColor.CGColor
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.cornerRadius = 5
        backgroundView.clipsToBounds = true
        seperateView.layer.borderColor = Config.textFieldBorderColor.CGColor
        seperateView.layer.borderWidth = 1
    }
    
    func setupButton(tag: Int, title: String, imageName: String?) {
        let button = view.viewWithTag(tag) as! UIButton
        button.setTitle(" " + title, forState: .Normal)
        if (imageName != nil) {
            button.setImage(UIImage(named: imageName!), forState: .Normal)
        }
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        delegate!.buttonTapped(sender.tag)
    }
}
