import UIKit

/// Controller for handling users sign-up operations
class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nickNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    
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
        let signInButton = UIBarButtonItem(title: "Sign in", style: .Plain, target: self, action: "navigateToSignIn")
        signInButton.tintColor = Config.signInButtonTintColor
        self.navigationItem.rightBarButtonItem = signInButton
        
        // Set focus for email field
        emailField.becomeFirstResponder();
        
        // Beautify the text fields
        for index in 1...4 {
            let textField = view.viewWithTag(index) as! UITextField
            textField.layer.cornerRadius = Config.textFieldBorderRadius
            textField.layer.borderWidth = Config.textFieldBorderWidth
            textField.layer.borderColor = Config.textFieldBorderColor.CGColor
            textField.delegate = self
        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            for index in 1...4 {
                let textField = view.viewWithTag(index) as! UITextField
                if (textField.isFirstResponder() && touch.view != textField) {
                    textField.resignFirstResponder()
                    break
                }
            }
        }
        super.touchesBegan(touches , withEvent:event)
    }
    
    func navigateToSignIn() {
        navigationController?.popToRootViewControllerAnimated(true)
        performSegueWithIdentifier("NavigateToSignIn", sender: nil)
    }

    @IBAction func signUp() {
        let email = emailField.text
        let nickName = nickNameField.text
        let password = passwordField.text
        let repeatPassword = repeatPasswordField.text
        
        // Check for empty fields
        if (email.isEmpty || nickName.isEmpty || password.isEmpty || repeatPassword.isEmpty) {
            Utilities.showAlert(self, message: "All fields required!")
            return
        }
        
        // Check if passwords march
        if (password != repeatPassword) {
            Utilities.showAlert(self, message: "Passwords do not match!")
            return
        }
        
        // Check if using Autodesk email
        let emailPair = email.componentsSeparatedByString("@")
        if (emailPair.count != 2 || emailPair[1] != "autodesk.com") {
            Utilities.showAlert(self, message: "Please use Autodesk email to register!")
            return
        }
        
        // Sign up request
        if (!User.currentUser.signUp(email, nickName: nickName, password: password)) {
            Utilities.showAlert(self, message: "Failed to sign up!")
            return
        }
        
        println(User.currentUser.userId)
        self.performSegueWithIdentifier("BackToChallengerFronSignUp", sender: self)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.tag < 4) {
            let nextTextField = view.viewWithTag(textField.tag + 1) as! UITextField
            nextTextField.becomeFirstResponder()
        }
        else {
            signUp()
        }
        return true
    }
}
