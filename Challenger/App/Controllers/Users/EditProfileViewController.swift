import UIKit

/// Controller for editing the user profile
class EditProfileViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var avatar: UIButton!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var nameToBeDisplay: UITextField!
    @IBOutlet weak var occupation: UITextField!
    
    var userID: String?
    var userEmail: String?
    var avatarImage: UIImage?
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Edit profile"
        if let font = UIFont(name: Config.fontFamilyLight, size: 16) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
        }
        
        // Beautify the text fields
        for index in 1...2 {
            let textField = view.viewWithTag(index) as! UITextField
            textField.layer.cornerRadius = Config.textFieldBorderRadius
            textField.layer.borderWidth = Config.textFieldBorderWidth
            textField.layer.borderColor = Config.textFieldBorderColor.CGColor
            textField.delegate = self
        }
        
        email.text = "Email: " + userEmail!
    }
    
    @IBAction func setAvatar() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = false
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func updateProfile() {
        if let avatarToUpload = avatarImage {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [unowned self] in
                HttpRequest.uploadImage(Config.uploadEndpoint, parameters: nil, filename: "picture", image: avatarToUpload, success: self.update)
            }
        } else {
            update("")
        }
    }
    
    func update(image: String) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            Contact.updateProfile(self.userID!, avatar: image, nickName: self.nameToBeDisplay.text, title: self.occupation.text)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        avatarImage = Utilities.cropToSquare(image: (info[UIImagePickerControllerOriginalImage] as? UIImage)!)
        
        avatar.setImage(avatarImage, forState: .Normal)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == nameToBeDisplay) {
            occupation.becomeFirstResponder()
        }
        else {
            occupation.resignFirstResponder()
            updateProfile()
        }
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            if (nameToBeDisplay.isFirstResponder() && touch.view != nameToBeDisplay) {
                nameToBeDisplay.resignFirstResponder()
            }
            if (occupation.isFirstResponder() && touch.view != occupation) {
                occupation.resignFirstResponder()
            }
        }
        super.touchesBegan(touches, withEvent:event)
    }
}
