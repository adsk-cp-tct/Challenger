import Foundation

/// User data model class
class User {
    class var currentUser: User {
        struct Static {
            static var instance: User?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = User()
        }
        
        return Static.instance!
    }
    
    private var currentUserName : String?
    private var currentUserId: String?
    var userId: String? {
        get {
            if currentUserId == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let name = defaults.stringForKey(Config.userIDStorageKey) {
                    currentUserId = name
                }
            }
            return currentUserId
        }
        set {
            currentUserId = newValue
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(currentUserId, forKey: Config.userIDStorageKey)
            defaults.synchronize()
        }
    }
    
    var userName: String? {
        get {
            if currentUserName == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let name = defaults.stringForKey(Config.userNameStorageKey) {
                    currentUserName = name
                }
            }
            return currentUserName
        }
        set {
            currentUserName = newValue
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(currentUserName, forKey: Config.userNameStorageKey)
            defaults.synchronize()
        }
    }
    
    private var currentAppliedEvents: [NSString]?
    var appliedEvents: [NSString] {
        get {
            if currentAppliedEvents == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let events: AnyObject = defaults.objectForKey(Config.userAppliedEventsStorageKey) {
                    currentAppliedEvents = events as? [NSString]
                }
                else {
                    // TODO, need to check from backend, to avoid incorrection across the devices
                }
            }
            return currentAppliedEvents ?? []
        }
        set {
            currentAppliedEvents = newValue
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(currentAppliedEvents, forKey: Config.userAppliedEventsStorageKey)
            defaults.synchronize()
        }
    }
    
    private var currentLikedEvents: [NSString]?
    var likedEvents: [NSString] {
        get {
            if currentLikedEvents == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let events: AnyObject = defaults.objectForKey(Config.userLikedEventsStorageKey) {
                    currentLikedEvents = events as? [NSString]
                }
                else {
                    // TODO, need to check from backend, to avoid incorrection across the devices
                }
            }
            return currentLikedEvents ?? []
        }
        set {
            currentLikedEvents = newValue
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(currentLikedEvents, forKey: Config.userLikedEventsStorageKey)
            defaults.synchronize()
        }
    }
    
    private var currentLikedIdeas: [NSString]?
    var likedIdeas: [NSString] {
        get {
            if currentLikedIdeas == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let ideas: AnyObject = defaults.objectForKey(Config.userLikedIdeasStorageKey) {
                    currentLikedIdeas = ideas as? [NSString]
                }
                else {
                    // TODO, need to check from backend, to avoid incorrection across the devices
                }
            }
            return currentLikedIdeas ?? []
        }
        set {
            currentLikedIdeas = newValue
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(currentLikedIdeas, forKey: Config.userLikedIdeasStorageKey)
            defaults.synchronize()
        }
    }
    
    private var currentFollowedEvents: [NSString]?
    var followedEvents: [NSString] {
        get {
            if currentFollowedEvents == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let events: AnyObject = defaults.objectForKey(Config.userFollowedEventsStorageKey) {
                    currentFollowedEvents = events as? [NSString]
                }
                else {
                    // TODO, need to check from backend, to avoid incorrection across the devices
                }
            }
            return currentFollowedEvents ?? []
        }
        set {
            currentFollowedEvents = newValue
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(currentFollowedEvents, forKey: Config.userFollowedEventsStorageKey)
            defaults.synchronize()
        }
    }
    
    private var currentFollowedIdeas: [NSString]?
    var followedIdeas: [NSString] {
        get {
            if currentFollowedIdeas == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let ideas: AnyObject = defaults.objectForKey(Config.userFollowedIdeasStorageKey) {
                    currentFollowedIdeas = ideas as? [NSString]
                }
                else {
                    // TODO, need to check from backend, to avoid incorrection across the devices
                }
            }
            return currentFollowedIdeas ?? []
        }
        set {
            currentFollowedIdeas = newValue
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(currentFollowedIdeas, forKey: Config.userFollowedIdeasStorageKey)
            defaults.synchronize()
        }
    }
    
    private var currentDeviceToken: String?
    var deviceToken: String? {
        get {
            return currentDeviceToken
        }
        set {
            currentDeviceToken = newValue
        }
    }
    
    /// User sign up
    func signUp(email: String, nickName: String, password: String) -> Bool {
        let signUpUserProfile = [
            "email"   : email,
            "nickName": nickName,
            "password": password
        ]
        let (response, error, responseContent) = HttpRequest.sendSynchronousJsonContentRequest(Config.signUpEndpoint, method: "POST", body: signUpUserProfile)
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Already registered")
                return false
            }
        }
        
        return signIn(email, password: password)
    }
    
    /// User sign in
    func signIn(email: String, password: String) -> Bool {
        let signInUserProfile = [
            "email"   : email,
            "password": password
        ]
        let (response, error, responseContent) = HttpRequest.sendSynchronousJsonContentRequest(Config.signInEndpoint, method: "POST", body: signInUserProfile)
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            userId = Utilities.getStringValue(jsonResult, forKey: "id")
            userName = Utilities.getStringValue(jsonResult, forKey: "nickName")
        }
        else {
            println("error")
            return false
        }
        
        if (User.currentUser.deviceToken != nil) {
            Utilities.postDeviceToken(userId!, deviceToken: User.currentUser.deviceToken!)
        }
        
        return true
    }
    
    /// User sign out, clean up the cache data
    func signOut() {
        Utilities.deleteDeviceToken(userId!)
        
        userId = nil
        userName = nil
        appliedEvents = []
        likedEvents = []
        likedIdeas = []
        followedEvents = []
        followedIdeas = []
    }
    
    /// Determine whether one event is registered by current user
    func isEventRegistered(eventId: String) -> Bool {
        for event in appliedEvents {
            if event == eventId {
                return true
            }
        }
        return false
    }
    
    /// Register one event for current user
    func registerEvent(eventId: String) -> Bool {
        let registerForm = [
            "eventId": eventId,
            "userId" : userId!
        ]
        let (response, error, responseContent) = HttpRequest.sendSynchronousJsonContentRequest(Config.registerEndpoint, method: "POST", body: registerForm)
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Failed to register")
                return false
            }
        }
        
        appliedEvents.append(eventId)
        return true
    }
    
    /// Unregister one event for current user
    func unregisterEvent(eventId: String) -> Bool {
        let unregisterForm = [
            "eventId": eventId,
            "userId" : userId!
        ]
        let (response, error, responseContent) = HttpRequest.sendSynchronousJsonContentRequest(Config.unregisterEndpoint, method: "POST", body: unregisterForm)
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Failed to unregister")
                return false
            }
        }
        
        for index in 0..<appliedEvents.count {
            if appliedEvents[index] == eventId {
                appliedEvents.removeAtIndex(index)
            }
        }
        return true
    }
    
    /// Determine whether one event is liked by current user
    func doesUserLikeEvent(eventId: String) -> Bool {
        for event in likedEvents {
            if event == eventId {
                return true
            }
        }
        return false
    }
    
    /// Like event for current user
    func likeEvent(eventId: String, title: String) -> Bool {
        let likeForm = [
            "eventId"   : eventId,
            "title"     : title,
            "likeUserId": userId!
        ]
        let (response, error, responseContent) = HttpRequest.sendSynchronousJsonContentRequest(Config.likeEventEndpoint, method: "POST", body: likeForm)
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Failed to like")
                return false
            }
        }
        
        likedEvents.append(eventId)
        return true
    }
    
    /// Unlike event for current user
    func unlikeEvent(eventId: String) -> Bool {
        let url = Config.likeEventEndpoint + "/" + eventId + "/" + userId!
        let (response, error, responseContent) = HttpRequest.sendSynchronousRequest(url, method: "DELETE")
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Failed to unlike")
                return false
            }
        }
        
        for index in 0..<likedEvents.count {
            if likedEvents[index] == eventId {
                likedEvents.removeAtIndex(index)
            }
        }
        return true
    }
    
    /// Determine whether one event is followed by current user
    func doesUserFollowEvent(eventId: String) -> Bool {
        for event in followedEvents {
            if event == eventId {
                return true
            }
        }
        return false
    }
    
    /// Follow event for current user
    func followEvent(eventId: String, title: String) -> Bool {
        let followForm = [
            "eventId"  : eventId,
            "title"    : title,
            "follower" : userId!
        ]
        let (response, error, responseContent) = HttpRequest.sendSynchronousJsonContentRequest(Config.followEventEndpoint, method: "POST", body: followForm)
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Failed to follow")
                return false
            }
        }
        
        followedEvents.append(eventId)
        return true
    }
    
    /// Unfollow event for current user
    func unfollowEvent(eventId: String) -> Bool {
        let url = Config.followEventEndpoint + "/" + eventId + "/" + userId!
        let (response, error, responseContent) = HttpRequest.sendSynchronousRequest(url, method: "DELETE")
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Failed to register")
                return false
            }
        }
        
        for index in 0..<followedEvents.count {
            if followedEvents[index] == eventId {
                followedEvents.removeAtIndex(index)
            }
        }
        return true
    }
    
    /// Determine whether one idea is liked by current user
    func doesUserLikeIdea(ideaId: String) -> Bool {
        for idea in likedIdeas {
            if idea == ideaId {
                return true
            }
        }
        return false
    }
    
    /// Like idea for current user
    func likeIdea(ideaId: String, title: String) -> Bool {
        let likeForm = [
            "ideaId"    : ideaId,
            "title"     : title,
            "likeUserId": userId!
        ]
        let (response, error, responseContent) = HttpRequest.sendSynchronousJsonContentRequest(Config.likeIdeaEndpoint, method: "POST", body: likeForm)
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Failed to like")
                return false
            }
        }
        
        likedIdeas.append(ideaId)
        return true
    }
    
    /// Unlike idea for current user
    func unlikeIdea(ideaId: String) -> Bool {
        let url = Config.likeIdeaEndpoint + "/" + ideaId + "/" + userId!
        let (response, error, responseContent) = HttpRequest.sendSynchronousRequest(url, method: "DELETE")
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Failed to unlike")
                return false
            }
        }
        
        for index in 0..<likedIdeas.count {
            if likedIdeas[index] == ideaId {
                likedIdeas.removeAtIndex(index)
            }
        }
        return true
    }
    
    /// Determine whether one idea is followed by current user
    func doesUserFollowIdea(ideaId: String) -> Bool {
        for idea in followedIdeas {
            if idea == ideaId {
                return true
            }
        }
        return false
    }
    
    /// Follow idea for current user
    func followIdea(ideaId: String, title: String) -> Bool {
        let followForm = [
            "ideaId"  : ideaId,
            "title"    : title,
            "follower" : userId!
        ]
        let (response, error, responseContent) = HttpRequest.sendSynchronousJsonContentRequest(Config.followIdeaEndpoint, method: "POST", body: followForm)
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Failed to follow")
                return false
            }
        }
        
        followedIdeas.append(ideaId)
        return true
    }
    
    /// Unfollow idea for current user
    func unfollowIdea(ideaId: String) -> Bool {
        let url = Config.followIdeaEndpoint + "/" + ideaId + "/" + userId!
        let (response, error, responseContent) = HttpRequest.sendSynchronousRequest(url, method: "DELETE")
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Failed to register")
                return false
            }
        }
        
        for index in 0..<followedIdeas.count {
            if followedIdeas[index] == ideaId {
                followedIdeas.removeAtIndex(index)
            }
        }
        return true
    }
    
    /// Follow user for current user
    func followUser(followUserId: String, followUserName: String) -> Bool {
        let followForm = [
            "user"         : followUserId,
            "userName"     : followUserName,
            "follower"     : userId!,
            "followerName" : userName!
        ]
        let (response, error, responseContent) = HttpRequest.sendSynchronousJsonContentRequest(Config.followUserEndpoint, method: "POST", body: followForm)
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Failed to follow")
                return false
            }
        }
        
        return true
    }
    
    /// Unfollow idea for current user
    func unfollowUser(followUserId: String) -> Bool {
        let url = Config.usersEndpoint + "/" + followUserId + "/" + userId!
        let (response, error, responseContent) = HttpRequest.sendSynchronousRequest(url, method: "DELETE")
        
        let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        if (error != nil || statusCode != 200) {
            println("Http error")
            return false
        }
        
        if let jsonResult = Utilities.parsedNSDataToDictionary(responseContent!) {
            if (Utilities.getStringValue(jsonResult, forKey: "status") == "fails") {
                println("Failed to register")
                return false
            }
        }
        
        return true
    }
}