import UIKit

/// Base Configurations
struct Config {
    /// The REST server endpoint
    static let endpoint = "http://challengerweb.ecs.ads.autodesk.com"
    
    /// The endpoint for a new user sign-up
    static var signUpEndpoint = endpoint + "/signup"
    
    /// The endpoint for user sing-in
    static var signInEndpoint = endpoint + "/signin"
    
    /// The endpoint for retrieving users
    static var usersEndpoint = endpoint + "/users"
    
    /// The endpoint for user registration
    static var registerEndpoint = usersEndpoint + "/register/event"
    static var unregisterEndpoint = endpoint + "/unregister/event"
    
    /// The endpoint for Contact
    static func contactEndpoint(userID: String) -> String {
        return usersEndpoint + "/" + userID + "/contacts"
    }
    
    /// The endpoint for Profile
    static func profileEndpoint(userID: String) -> String {
        return usersEndpoint + "/" + userID + "/profile"
    }
    
    /// The endpoint for Events
    static func userAppliedEventsEndpoint(userID: String) -> String {
        return usersEndpoint + "/" + userID + "/applyingEvents"
    }
    static func userRegisterEventsEndpoint(userID: String) -> String {
        return usersEndpoint + "/" + userID + "/registeredEvents"
    }
    
    /// The endpoint for post idea
    static func postedIdeasEndpoint(userID: String) -> String {
        return endpoint + "/ideas/" + userID
    }
    
    /// The endpoint for Events
    static var eventsEndpoint = endpoint + "/events"
    static var likeEventEndpoint = endpoint + "/like/event"
    static var followEventEndpoint = endpoint + "/follow/event"
    
    /// The endpoint for Comments
    static var commentEndpoint = endpoint + "/comment"
    
    /// The endpoint for Activity
    static var activityEndpoint = endpoint + "/activities"
    
    /// The endpoint for Idea
    static var ideaEndpoint = endpoint + "/idea"
    static var likeIdeaEndpoint = endpoint + "/like/idea"
    static var followIdeaEndpoint = endpoint + "/follow/idea"
    
    /// The endpoint for follow user
    static var followUserEndpoint = endpoint + "/follow/user"
    
    /// The endpoint for device token
    static var tokenEndpoint = endpoint + "/token"
    
    /// The endpoint for Image
    static var imageEndpoint = endpoint + "/images/"
    static var uploadEndpoint = endpoint + "/image"
    
    /// Color constants
    static let baseBackgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
    static let greenBackgroundColor = UIColor(red: 0, green: 169/255, blue: 157/255, alpha: 1)
    static let signInButtonTintColor = UIColor(red: 0.42, green: 0.75, blue: 0.91, alpha: 1)
    static let signUpButtonTintColor = UIColor(red: 0.62, green: 0.85, blue: 0.82, alpha: 1)
    static let textFieldBorderColor = UIColor(red: 0.02, green: 0.58, blue: 0.83, alpha: 1)
    static let textFieldBorderRadius: CGFloat = 5.0
    static let textFieldBorderWidth: CGFloat = 1.0
    
    static let buttonFontSize: CGFloat = 16
    static let fontFamilyThin = "HelveticaNeue-Thin"
    static let fontFamilyLight = "HelveticaNeue-Light"
    
    /// StorageKey constants
    static let userIDStorageKey = "User.id"
    static let userNameStorageKey = "User.name" 
    static let userAppliedEventsStorageKey = "User.appliedEvents"
    static let userLikedEventsStorageKey = "User.likedEvents"
    static let userFollowedEventsStorageKey = "User.followedEvents"
    static let userLikedIdeasStorageKey = "User.likedIdeas"
    static let userFollowedIdeasStorageKey = "User.followedIdeas"
    
    enum eventType: String {
        case Event = "event"
        case Idea = "idea"
    }
}