import Foundation

/// Contact data model class
class Contact {
    var id = ""
    var name = ""
    var title = ""
    var email = ""
    var avatar = ""
    var followUsers: [String] = []
    
    /// Get all contacts data for one user
    static func getContacts() -> [Contact] {
        let (response, responseError, responseContent) = HttpRequest.sendSynchronousRequest(Config.contactEndpoint(User.currentUser.userId!), method: "GET")
        
        var contacts: [Contact] = []
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (responseError != nil || statusCode != 200 || responseContent == nil) {
            println("error")
            return contacts
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            // process jsonResult
            if let contactsArray = jsonResult["contacts"] as? NSArray{
                for e in contactsArray {
                    let contact = Contact()
                    contact.id     = Utilities.getStringValue(e, forKey: "id")
                    contact.name   = Utilities.getStringValue(e, forKey: "nickName")
                    contact.title = Utilities.getStringValue(e, forKey: "description")
                    contact.email  = Utilities.getStringValue(e, forKey: "email")
                    contact.avatar = Utilities.getImagePath(e, forKey: "avatar", withDefault: "default-avatar")
                    
                    if let followUsers = jsonResult["followUsers"] as? NSArray{
                        for followUser in followUsers {
                            if let followUserVal: String = followUser as? String {
                                if (!followUserVal.isEmpty) {
                                    contact.followUsers.append(followUserVal as String)
                                }
                            }
                        }
                    }
                    
                    contacts.append(contact)
                }
            }
        }
        else {
            // couldn't load JSON, look at error
            println("error")
        }
        
        return contacts
    }
    
    /// Get contact profile
    static func getProfile(userId: String) -> Contact {
        let profileEndpoint = Config.profileEndpoint(userId)
        let (response, responseError, responseContent) = HttpRequest.sendSynchronousRequest(profileEndpoint, method: "GET")
        
        var profile = Contact()
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (responseError != nil || statusCode != 200 || responseContent == nil) {
            println("error")
            return profile
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            // process jsonResult
            profile.id = Utilities.getStringValue(jsonResult, forKey: "id")
            profile.name   = Utilities.getStringValue(jsonResult, forKey: "nickName")
            profile.title = Utilities.getStringValue(jsonResult, forKey: "description")
            profile.email  = Utilities.getStringValue(jsonResult, forKey: "email")
            profile.avatar = Utilities.getImagePath(jsonResult, forKey: "avatar", withDefault: "default-avatar")
            
            if let followUsers = jsonResult["followUsers"] as? NSArray{
                for followUser in followUsers {
                    if let followUserVal: String = followUser as? String {
                        if (!followUserVal.isEmpty) {
                            profile.followUsers.append(followUserVal as String)
                        }
                    }
                }
            }
        }
        else {
            // couldn't load JSON, look at error
            println("error")
        }
        
        return profile
    }
    
    /// Update user profile
    static func updateProfile(userID: String, avatar:String, nickName: String, title: String) -> Bool{
        
        var postBody: [String : String] = [:]
        postBody["avatar"] = avatar
        postBody["nickName"] = nickName
        User.currentUser.userName = nickName
        postBody["description"] = title
        
        // Nothing to update
        if (postBody.isEmpty) {
            return true
        }
        
        let profileEndpoint = Config.profileEndpoint(userID)
        let (response, error, responseContent) = HttpRequest.sendSynchronousJsonContentRequest(profileEndpoint, method: "POST", body: postBody)
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Update profile failed")
                return false
            }
        }
        
        return true
    }
}