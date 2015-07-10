import Foundation

/// Idea data model class
class Idea{
    var id = ""
    var title = ""
    var description = ""
    var thumbnails = ""
    var createdBy = ""
    var createdUser = ""
    var createdAvatar = ""
    var createdEmail = ""
    var createdDescription = ""
    var createdTime = ""
    var like = ""
    var likeUserCount = ""
    var followers: Dictionary<String, String> = [String: String]()
    var followersCount = ""
    var commentsCount = ""
    
    /// Post idea
    static func postIdea(title: String, description:String, thumbnails: [String], createdBy: String, userId: String) -> Bool{
        
        let ideaBody = (thumbnails.count > 0 ?
            [
                "title" : title,
                "description" : description,
                "thumbnails" : thumbnails,
                "user" : createdBy,
                "userId" : userId
            ]
            :
            [
                "title" : title,
                "description" : description,
                "user" : createdBy,
                "userId" : userId
            ])
        
        let (response, error, responseContent) = HttpRequest.sendSynchronousJsonContentRequest(Config.ideaEndpoint, method: "POST", body: ideaBody)
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("post idea failed")
                return false
            }
            println(Utilities.getStringValue(jsonResult, forKey: "id"))
        }
        
        return true
    }
    
    /// Get ideas data
    static func getIdeas(byUser: String) -> [Idea] {
        // TODO, support event filter later
        let url = byUser.isEmpty ? Config.ideaEndpoint : Config.postedIdeasEndpoint(byUser)
        
        let (response, responseError, responseContent) = HttpRequest.sendSynchronousRequest(url, method: "GET")
        
        var ideas: [Idea] = []
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (responseError != nil || statusCode != 200 || responseContent == nil) {
            println("error")
            return ideas
        }
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            // process jsonResult
            if let ideasArray = jsonResult["ideas"] as? NSArray{
                for i in ideasArray {
                    let idea = Idea()
                    idea.id = Utilities.getStringValue(i, forKey: "id")
                    idea.title = Utilities.getStringValue(i, forKey: "title")
                    idea.description = Utilities.getStringValue(i, forKey: "description")
                    idea.likeUserCount = Utilities.getStringValue(i, forKey: "likeUserCount", withDefault: "0")
                    idea.like = Utilities.getArraySizeValue(i, forKey: "likedUsers")
                    idea.followersCount = Utilities.getStringValue(i, forKey: "followersCount", withDefault: "0")
                    idea.followers = Utilities.getMapValue(jsonResult, forKey: "followers")
                    
                    for (userId, userAvatar) in idea.followers {
                        if (userAvatar.isEmpty) {
                            idea.followers[userId] = "default-avatar"
                        } else {
                            idea.followers[userId] = Config.imageEndpoint + userAvatar
                        }
                    }
                    
                    let thumbnails = Utilities.getStringArrayValue(i, forKey: "thumbnails")
                    idea.thumbnails = Config.imageEndpoint + (thumbnails.count==0 ? "DefaultThumbnail" : thumbnails[0])
                    idea.createdBy = Utilities.getStringValue(i, forKey: "createdBy")
                    idea.createdTime = Utilities.getStringValue(i, forKey: "createdTime")
                    ideas.append(idea)
                }
            }
        }
        else {
            // couldn't load JSON, look at error
            println("error")
        }
        
        return ideas
    }
    
    /// Get one specified idea data
    static func getIdea(ideaId: String) -> Idea {
        let idea = Idea()
        idea.id = ideaId
        
        let url : String = Config.ideaEndpoint + "/" + ideaId
        let (response, responseError, responseContent) = HttpRequest.sendSynchronousRequest(url, method: "GET")
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (responseError != nil || statusCode != 200 || responseContent == nil) {
            println("error")
            return idea
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            idea.id = Utilities.getStringValue(jsonResult, forKey: "id")
            idea.title = Utilities.getStringValue(jsonResult, forKey: "title")
            idea.description = Utilities.getStringValue(jsonResult, forKey: "description")
            idea.likeUserCount = Utilities.getArraySizeValue(jsonResult, forKey: "likedUsers")
            idea.like = Utilities.getArraySizeValue(jsonResult, forKey: "likedUsers")
            idea.followersCount = Utilities.getDictionarySizeValue(jsonResult, forKey: "followers")
            idea.followers = Utilities.getMapValue(jsonResult, forKey: "followers")
            
            for (userId, userAvatar) in idea.followers {
                if (userAvatar.isEmpty) {
                    idea.followers[userId] = "default-avatar"
                } else {
                    idea.followers[userId] = Config.imageEndpoint + userAvatar
                }
            }
            let thumbnails = Utilities.getStringArrayValue(jsonResult, forKey: "thumbnails")
            idea.thumbnails = Config.imageEndpoint + (thumbnails.count==0 ? "DefaultThumbnail" : thumbnails[0])
            idea.createdBy = Utilities.getStringValue(jsonResult, forKey: "createdBy")
            idea.createdUser = Utilities.getStringValue(jsonResult, forKey: "createdUser")
            idea.createdAvatar = Utilities.getImagePath(jsonResult, forKey: "createdAvatar", withDefault: "default-avatar")
            idea.createdEmail = Utilities.getStringValue(jsonResult, forKey: "createdEmail")
            idea.createdDescription = Utilities.getStringValue(jsonResult, forKey: "createdDescription")
            idea.createdTime = Utilities.getStringValue(jsonResult, forKey: "createdTime")
            idea.commentsCount = Utilities.getArraySizeValue(jsonResult, forKey: "comments")
        }
        else {
            // couldn't load JSON, look at error
            println("error")
        }
        
        return idea
    }

}