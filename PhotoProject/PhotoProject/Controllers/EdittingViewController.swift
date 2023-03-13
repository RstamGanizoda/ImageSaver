import UIKit

//MARK: - Extensions
private extension CGFloat {
    static let paddingTextField = CGFloat(10)
    static let upgradeBottomConstraint = CGFloat(15)
}

private extension String {
    static let PlaceholderComment = "Edit your comment"
}

private extension UIImage {
    static let filledHeart = UIImage(systemName: "heart.fill")
    static let heart = UIImage(systemName: "heart")
}

//MARK: - Protocols
protocol EdittingViewControllerDelegate : AnyObject {
    func reloadCollectionView()
    func EdittingViewControllerDidDeleteImage(at index: Int)
}

//MARK: - Classes
class EdittingViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!

    //MARK: - let/var
    weak var delegate : EdittingViewControllerDelegate?
    var isLiked: Bool?
    var image: UIImage?
    var comment: String?
    var imageName: String?
    var index: Int?
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addAllUI()
        loadPrevousData()
    }

    //MARK: - IBAction
    @IBAction func backButtonPressed(_ sender: UIButton) {
        backToPreviousVC()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        updateData()
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        likePhoto()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        deletePhoto()
    }
    
    //MARK: - Navigation
    private func backToPreviousVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UI
    private func addAllUI(){
        modifyButtons()
        modifyCommentTextField()
        addTapGestureRecognizer()
        registerForKeyboardNotification()
    }
    
    private func modifyButtons() {
        backButton.buttonParameters()
        backButton.dropShadow()
        saveButton.buttonParameters()
        saveButton.dropShadow()
        deleteButton.buttonParameters()
        deleteButton.dropShadow()
    }
    
    private func registerForKeyboardNotification(){
        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardChanged(_:)),
                name: UIResponder.keyboardWillShowNotification,
                object: nil
            )
        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardChanged(_:)),
                name: UIResponder.keyboardWillHideNotification,
                object: nil
            )
    }
    
    @objc func keyboardChanged(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
              let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            bottomConstraint.constant = .zero
        } else {
            bottomConstraint.constant = frame.height + .upgradeBottomConstraint
        }
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func modifyCommentTextField() {
        let placeholderComment = NSAttributedString(
            string: .PlaceholderComment,
            attributes: [NSAttributedString
                .Key
                .foregroundColor: UIColor.darkGray]
        )
        let paddingView = UIView(
            frame: CGRect(
                x: commentTextField.frame.origin.x,
                y: commentTextField.frame.origin.y,
                width: .paddingTextField,
                height: commentTextField.frame.size.height
            )
        )
        commentTextField.textFieldParameters()
        commentTextField.textFieldsSettings(placeholderComment, paddingView)
    }
    
    //MARK: Functionality
    private func loadPrevousData() {
        mainImageView.image = image
        commentTextField.text = comment
        if isLiked == true {
            likeButton.setImage(.filledHeart, for: .normal)
        } else {
            likeButton.setImage(.heart, for: .normal)
        }
    }
    
    private func deletePhoto() {
        delegate?.EdittingViewControllerDidDeleteImage(at: self.index ?? .zero)
        addSuccessAlert(message: "Photo has been deleted")
    }
    
    private func updateData() {
        guard let imageName = imageName,
              let comment = commentTextField.text,
              let isLiked = isLiked else { return }
        StorageManager.shared.updateImage(
            imageName: imageName,
            newComment: comment,
            isLiked: isLiked)
        delegate?.reloadCollectionView()
        addSuccessAlert(message: "Information has been updated")
    }
    
    private func addSuccessAlert(message: String){
        presentAlertWithTitle(
            title: "Success",
            message: message,
            options: "OK"
        ) { (option) in
            switch(option) {
            case "OK":
                self.backToPreviousVC()
                break
            default:
                break
            }
        }
    }
    
    private func likePhoto() {
        self.isLiked?.toggle()
        
        if self.isLiked == true {
            likeButton.setImage(.filledHeart, for: .normal)
        } else {
            likeButton.setImage(.heart, for: .normal)
        }
    }
}

//MARK: - Extensions
extension EdittingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentTextField.resignFirstResponder()
        return true
    }
}
