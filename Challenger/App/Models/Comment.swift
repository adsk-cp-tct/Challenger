import Foundation
import UIKit

/// Comment data model class
class Comment {
    var id = ""
    var userId = ""
    var userName = ""
    var content = ""
    var createdTime = ""
    var userAvatar = ""
    
    //var commentForEvents:[Comment]=[]
    
    /// Get comments data
    static func getComments(targetType: Config.eventType, targetId: String) -> [Comment]{
        var url = ""
        
        switch targetType {
        case Config.eventType.Event: url = Config.eventsEndpoint + "/" + targetId
        case Config.eventType.Idea: url = Config.ideaEndpoint + "/" + targetId
        default: url = Config.eventsEndpoint + "/" + targetId
        }
        
        let (response,responseError,responseContent) = HttpRequest.sendSynchronousRequest(url, method: "Get")
        
        var comments:[Comment]=[]
        let statusCode=(response as? NSHTTPURLResponse)?.statusCode ?? -1
        
        if (responseError != nil || statusCode != 200 || responseContent == nil) {
            println("error")
            return comments
        }
        
        println(targetId)
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!){
            if let commentsArray = jsonResult["comments"] as? NSArray{
                for c in commentsArray{
                    let comment = Comment()
                    comment.id = Utilities.getStringValue(c, forKey:"id")
                    comment.userId = Utilities.getStringValue(c, forKey:"userId")
                    comment.userName         = Utilities.getStringValue(c, forKey:"userName")
                    comment.content = Utilities.getStringValue(c, forKey:"content")
                    comment.createdTime     = Utilities.getStringValue(c, forKey:"createdTime")
                    comment.userAvatar        = Utilities.getImagePath(c, forKey:"userAvatar", withDefault: "default-avatar")
                    comments.append(comment)
                }
            }
        }
        else{
            println("error")
        }
        println(comments.count)
        return comments
        
    }
    
    /// Post comment
    static func postComment(targetId : String, targetTitle : String, targetType: Config.eventType, commentContent:String)->[Comment]{
        let commentBody=[
            "targetId":targetId,
            "targetTitle":targetTitle,
            "targetType":targetType.rawValue,
            "userId":User.currentUser.userId!,
            "comment":commentContent
        ]
        println(commentBody)
        let (response, error, responseContent) = HttpRequest.sendSynchronousJsonContentRequest(Config.commentEndpoint, method: "POST", body: commentBody)
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("post comment failed")
            }
        }
        
        return getComments(targetType, targetId: targetId)
    }
    
    /// Delete comment
    static func deleteCommentRequest(commentId : String){
        let url:String = Config.commentEndpoint+"/"+commentId
        let (response,responseError,responseContent) = HttpRequest.sendSynchronousRequest(url, method: "Delete")
        
        
        let statusCode=(response as? NSHTTPURLResponse)?.statusCode ?? -1
        
        if (responseError != nil || statusCode != 200 || responseContent == nil) {
            println("error")
        }
    }
    
    static func calculateCommentCellHeight(comment: String, width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width - 73, height: 10000))
        label.text = comment
        label.numberOfLines = 0
        label.font = UIFont(name: Config.fontFamilyLight, size: 13)
        label.sizeToFit()
        return label.frame.height + 30
    }
    
    static func assembleComment(userName: String, content: String) -> String {
        return userName + ": " + content
    }
}