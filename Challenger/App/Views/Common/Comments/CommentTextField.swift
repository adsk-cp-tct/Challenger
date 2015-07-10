import UIKit

protocol CommentTextFieldDelegate {
    func postCommentCallback(heightToAdd: CGFloat)
}

class CommentTextField: UIView, UITextFieldDelegate {

    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    var id: String?
    var type: Config.eventType?
    var eventTitle: String?
    var delegate: CommentTextFieldDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func whenAppear() {
        commentTextField.becomeFirstResponder()
        commentTextField.text = ""
    }
    
    @IBAction func postComment() {
        if (!commentTextField.text.isEmpty) {
            let eventIdStr = id!
            let commentContentStr = commentTextField.text
            let eventTitleStr = eventTitle!
            println("posted comment with content : " + commentContentStr)
            commentTextField.resignFirstResponder()
            Comment.postComment(eventIdStr, targetTitle: eventTitleStr, targetType: type!, commentContent: commentContentStr)
            
            delegate?.postCommentCallback(Comment.calculateCommentCellHeight(Comment.assembleComment(User.currentUser.userName!, content: commentContentStr), width: view.frame.width))
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        postComment()
        return true
    }

    private func setup() {
        NSBundle.mainBundle().loadNibNamed("CommentTextField", owner: self, options: nil)
        self.addSubview(view)
        
        commentTextField.layer.cornerRadius = Config.textFieldBorderRadius
        commentTextField.layer.borderWidth = Config.textFieldBorderWidth
        commentTextField.layer.borderColor = Config.textFieldBorderColor.CGColor
        commentTextField.delegate = self
    }
}
