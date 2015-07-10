import UIKit

/// Controller for handling users sign-in operations
class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        // Show the navigation bar
        self.navigationController?.navigationBarHidden = false;
        
        // Set right button for navigate to Sign in
        let signUpButton = UIBarButtonItem(title: "Sign up", style: .Plain, target: self, action: "navigateToSignUp")
        signUpButton.tintColor = Config.signUpButtonTintColor
        self.navigationItem.rightBarButtonItem = signUpButton
        
        // Set focus for email field
        emailField.becomeFirstResponder()
        
        // Beautify the text fields
        for index in 1...2 {
            let textField = view.viewWithTag(index) as! UITextField
            textField.layer.cornerRadius = Config.textFieldBorderRadius
            textField.layer.borderWidth = Config.textFieldBorderWidth
            textField.layer.borderColor = Config.textFieldBorderColor.CGColor
            textField.delegate = self
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            for index in 1...2 {
                let textField = view.viewWithTag(index) as! UITextField
                if (textField.isFirstResponder() && touch.view != textField) {
                    textField.resignFirstResponder()
                    break
                }
            }
        }
        super.touchesBegan(touches , withEvent:event)
    }
    
    func navigateToSignUp() {
        navigationController?.popToRootViewControllerAnimated(true)
        performSegueWithIdentifier("NavigateToSignUp", sender: nil)
    }
    
    @IBAction func signIn() {
        let email = emailField.text
        let password = passwordField.text
        
        // Check for empty fields
        if (email.isEmpty || password.isEmpty) {
            Utilities.showAlert(self, message: "All fields required!")
            return
        }

        // Sign in request
        if (!User.currentUser.signIn(email, password: password)) {
            Utilities.showAlert(self, message: "Failed to sign in!")
            return
        }
        
        println(User.currentUser.userId)
        self.performSegueWithIdentifier("BackToChallengerFronSignIn", sender: self)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.tag == 1) {
            let nextTextField = view.viewWithTag(2) as! UITextField
            nextTextField.becomeFirstResponder()
        }
        else {
            signIn()
        }
        return true
    }
}
