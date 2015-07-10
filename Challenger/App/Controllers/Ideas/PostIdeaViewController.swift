import UIKit

/// Controller for posting ideas
class PostIdeaViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var ideaTile: UITextField!
    @IBOutlet weak var ideaContent: UITextView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var addPhotoButtonHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var addPhotoButtonWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var addPhotoButtonLeadingConstraints: NSLayoutConstraint!
    
    private let ideaContentPlaceHolder = "Your ideas..."
    private var thumbnailSize: CGFloat!
    private var photoDistance: CGFloat!
    private var photos: [UIImageView] = []
    private var uploadedImages: [String] = []
    
    var imagePicker: UIImagePickerController!
    
    @IBAction func addPhoto(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = false
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func btnPost(sender: AnyObject) {
        if photos.count > 0 {
            for photo in photos {
                if let i = photo.image {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [unowned self] in
                        HttpRequest.uploadImage(Config.uploadEndpoint, parameters: nil, filename: "picture", image: i, success: self.appendImage)
                    }
                }
            }
        } else {
            Idea.postIdea(ideaTile.text, description: ideaContent.text, thumbnails: [], createdBy: User.currentUser.userName!, userId: User.currentUser.userId!)
            navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func appendImage(image: String) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.uploadedImages.append(image)
            if self.uploadedImages.count == self.photos.count { 
                Idea.postIdea(self.ideaTile.text, description: self.ideaContent.text, thumbnails: self.uploadedImages, createdBy: User.currentUser.userName!, userId: User.currentUser.userId!)
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        let i = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        var photo = UIImageView(image: i)
        var photoOriginX: CGFloat
        if photos.count == 0 {
            photoOriginX = addPhotoButton.frame.origin.x + photoDistance
        } else {
            photoOriginX = photos.last!.frame.maxX + photoDistance
        }
        let photoOriginY = addPhotoButton.frame.origin.y
        photo.frame = CGRect(x: photoOriginX, y: photoOriginY, width: thumbnailSize, height: thumbnailSize)
        view.addSubview(photo)
        
        photos.append(photo)
        if (photos.count == 4) {
            addPhotoButton.hidden = true
        } else {
            addPhotoButtonLeadingConstraints.constant = photo.frame.maxX + photoDistance
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the navigation item title
        self.navigationItem.title = "Post Idea"
        if let font = UIFont(name: Config.fontFamilyLight, size: 16) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
        }
        
        // Beautify the title text fields
        ideaTile.layer.cornerRadius = Config.textFieldBorderRadius
        ideaTile.layer.borderWidth = Config.textFieldBorderWidth
        ideaTile.layer.borderColor = Config.textFieldBorderColor.CGColor
        ideaTile.delegate = self
        
        // Beautify the idea text view
        ideaContent.text = ideaContentPlaceHolder
        ideaContent.textColor = UIColor.lightGrayColor()
        ideaContent.layer.cornerRadius = Config.textFieldBorderRadius
        ideaContent.layer.borderWidth = Config.textFieldBorderWidth
        ideaContent.layer.borderColor = Config.textFieldBorderColor.CGColor
        ideaContent.delegate = self
        
        // Turn off automaticallyAdjustsScrollViewInsets to make sure the text view start from the first line
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Beautify upload photos
        if (photos.isEmpty) {
            let addPhotoButtonX = addPhotoButton.frame.origin.x
            photoDistance = addPhotoButtonX / 5.0
            thumbnailSize = (view.bounds.width - addPhotoButtonX * 3.0) / 4.0
            addPhotoButtonHeightConstraints.constant = thumbnailSize
            addPhotoButtonWidthConstraints.constant = thumbnailSize
            self.updateViewConstraints()
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            if (ideaContent.isFirstResponder() && touch.view != ideaContent) {
                ideaContent.resignFirstResponder()
            }
            if (ideaTile.isFirstResponder() && touch.view != ideaTile) {
                ideaTile.resignFirstResponder()
            }
        }
        super.touchesBegan(touches , withEvent:event)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        ideaTile.resignFirstResponder()
        return true
    }

    func textViewDidBeginEditing(textView: UITextView) {
        if (ideaContent.text == ideaContentPlaceHolder) {
            ideaContent.text = ""
            ideaContent.textColor = UIColor.blackColor()
        }
        ideaContent.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (ideaContent.text == "") {
            ideaContent.text = ideaContentPlaceHolder
            ideaContent.textColor = UIColor.lightGrayColor()
        }
        ideaContent.resignFirstResponder()
    }
}