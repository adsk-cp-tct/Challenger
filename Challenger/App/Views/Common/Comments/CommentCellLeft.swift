import UIKit

class CommentCellLeft: CommentCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        commentContentView.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func loadComment(c: Comment){
        super.loadComment(c)
        
        var commentContent = NSMutableAttributedString(string: Comment.assembleComment(self.comment.userName, content: self.comment.content), attributes: [NSFontAttributeName:UIFont(name: Config.fontFamilyLight, size: 13.0)!])
        
        commentContent.addAttribute(NSForegroundColorAttributeName, value: Config.textFieldBorderColor, range: NSRange(location:0, length:count(self.comment.userName)))
        self.commentDetails.attributedText = commentContent
    }
}
