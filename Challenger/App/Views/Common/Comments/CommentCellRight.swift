import UIKit

class CommentCellRight: CommentCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        commentContentView.backgroundColor = Config.greenBackgroundColor
        commentContentView.layer.borderColor = Config.greenBackgroundColor.CGColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func loadComment(c: Comment){
        super.loadComment(c)
        
        self.commentDetails.text = Comment.assembleComment(self.comment.userName, content: self.comment.content)
    }
    
}
