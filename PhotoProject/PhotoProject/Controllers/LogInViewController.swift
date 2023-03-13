import UIKit

//MARK: - Extensions
private extension CGFloat {
    static let buttonBorderWidth = CGFloat(0.5)
    static let cornerRadius = CGFloat(10)
    static let paddingTextField = CGFloat(10)
    static let alphaForTextField = CGFloat(0.2)
    static let shadowRadius = CGFloat(15)
}

private extension Double {
    static let shadowOpacity = 0.5
    static let widthShadowOffset = 5.0
    static let heightShadowOffset = 8.0
}

private extension String {
    static let nicknamePlaceholder = "Your nickname"
    static let passwordPlaceholder = "Your password"
}

class LogInViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    //MARK: - let/var
    private let mainViewController = "MainViewController"
    private let storageManager = StorageManager.shared
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addAllUI()
    }
    
    //MARK: - IBAction
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        signInUser()
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        signUpUser()
    }
    
    //MARK: - Navigation
    private func createMainViewController(_ loadedUser: String?) {
        guard let controller = self.storyboard?
            .instantiateViewController(withIdentifier: mainViewController) as? MainViewController else {
            return
        }
        controller.username = loadedUser
        self.navigationController?
            .pushViewController(
                controller,
                animated: true)
    }
    
    //MARK: - UI
    private func addAllUI() {
        addLogo()
        modifyButtons()
        modifySearchTextField()
        addTapRecognizer()
    }
    
    private func addLogo() {
        let logoName = "mainLogo"
        let logo = UIImage(named: logoName)
        self.logoImageView.image = logo
    }
    
    private func modifyButtons() {
        signInButton.buttonParameters()
        signInButton.dropShadow()
        signUpButton.buttonParameters()
        signUpButton.dropShadow()
    }
    
    private func modifySearchTextField() {
        let placeholderNickname = NSAttributedString(
            string: .nicknamePlaceholder,
            attributes: [NSAttributedString
                .Key
                .foregroundColor: UIColor.darkGray]
        )
        let placeholderPassword = NSAttributedString(
            string: .passwordPlaceholder,
            attributes: [NSAttributedString
                .Key
                .foregroundColor: UIColor.darkGray]
        )
        let paddingViewForNickname = UIView(
            frame: CGRect(
                x: nicknameTextField.frame.origin.x,
                y: nicknameTextField.frame.origin.y,
                width: .paddingTextField,
                height: nicknameTextField.frame.size.height
            )
        )
        let paddingViewForPassword = UIView(
            frame: CGRect(
                x: passwordTextField.frame.origin.x,
                y: passwordTextField.frame.origin.y,
                width: .paddingTextField,
                height: passwordTextField.frame.size.height
            )
        )
        nicknameTextField.textFieldParameters()
        nicknameTextField.textFieldsSettings(placeholderNickname, paddingViewForNickname)
        passwordTextField.textFieldParameters()
        passwordTextField.textFieldsSettings(placeholderPassword, paddingViewForPassword)
        passwordTextField.isSecureTextEntry = true
    }
    
    private func addTapRecognizer(){
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Functionality
    private func signInUser() {
        let username = nicknameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if storageManager.signIn(
            username: username,
            password: password
        ) {
            createMainViewController(username)
        }
        nicknameTextField.text = nil
        passwordTextField.text = nil
    }
    
    private func signUpUser(){
        let username = nicknameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        storageManager.signUp(
            username: username,
            password: password
        )
        nicknameTextField.text = nil
        passwordTextField.text = nil
    }
}
//MARK: - Extensions
extension LogInViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nicknameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
}

extension UIView {
    func buttonParameters(
        radius: CGFloat = .cornerRadius,
        backgroundColor: UIColor = .lightGray,
        borderWidth: CGFloat = .buttonBorderWidth
    ) {
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
        self.backgroundColor = backgroundColor
    }
    
    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = Float(.shadowOpacity)
        self.layer.shadowOffset = CGSize(width: .widthShadowOffset,
                                         height: .heightShadowOffset)
        self.layer.shadowRadius = .shadowRadius
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.layer.cornerRadius
        ).cgPath
    }
    
    func textFieldParameters(
        cornerRadius: CGFloat = .cornerRadius,
        borderColor: CGColor = UIColor.black.cgColor,
        backgroundColor: UIColor = .systemGray.withAlphaComponent(.alphaForTextField)
    ) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = borderColor
        self.backgroundColor = backgroundColor
    }
}

extension UITextField {
    func textFieldsSettings(
        _ placeholderText: NSAttributedString,
        _ paddingView: UIView
    ){
        self.leftView = paddingView
        self.attributedPlaceholder = placeholderText
        self.textColor = .black
        self.leftViewMode = .always
        self.clearButtonMode = .always
        self.clearsOnBeginEditing = true
        self.autocapitalizationType = .words
    }
}
