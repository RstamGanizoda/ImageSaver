import UIKit

//MARK: - Extensions
private extension CGFloat {
    static let paddingTextField = CGFloat(10)
    static let upgradeBottomConstraint = CGFloat(15)
}

private extension String {
    static let PlaceholderComment = "Add your comment to the image"
}

private extension UIImage {
    static let filledHeart = UIImage(systemName: "heart.fill")
    static let heart = UIImage(systemName: "heart")
}

//MARK: - Protocols
protocol AddingImageViewControllerDelegate : AnyObject {
    func reloadCollectionView()
}

//MARK: - Classes
class AddingImageViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var mainPhotoImageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    //MARK: - let/var
    weak var delegate : AddingImageViewControllerDelegate?
    var imageArray: [Image]? = User.shared.photos
    let plusImage = UIImage(systemName: "plus")
    var isLiked = false
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addAllUI()
        loadPreviousImages()
    }
    
    //MARK: - IBAction
    @IBAction func backButtonPressed(_ sender: UIButton) {
        moveToPreviousViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveImage()
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        likePhoto()
    }
    
    //MARK: - Navigation
    private func moveToPreviousViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UI
    private func addAllUI(){
        modifyButtons()
        modifyCommentTextField()
        addTapGestureRecognizer()
        registerForKeyboardNotification()
        mainPhotoImageView.image = plusImage
    }
    
    private func modifyButtons() {
        backButton.buttonParameters()
        backButton.dropShadow()
        saveButton.buttonParameters()
        saveButton.dropShadow()
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
        let imageRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(imageTapDetected(_:))
        )
        self.mainPhotoImageView.addGestureRecognizer(imageRecognizer)
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        view.addGestureRecognizer(tap)
    }
    
    @objc private func imageTapDetected(_  recognizer: UITapGestureRecognizer) {
        self.pickImage()
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
    
    //MARK: - Functionality
    private func pickImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        }
    }
    
    private func loadPreviousImages() {
        if StorageManager.shared.getImages()?.isEmpty == false {
            imageArray = StorageManager.shared.getImages()
        } else {
            imageArray = []
        }
    }
    
    private func addNewImage(){
        guard let image = self.mainPhotoImageView.image,
              let imageName = StorageManager.shared.saveImage(image) else {return}
        let current = Image(
            imageName: imageName,
            comment: commentTextField.text,
            isLiked: self.isLiked
        )
        imageArray?.append(current)
        StorageManager.shared.saveImages(photo: imageArray ?? [])
        delegate?.reloadCollectionView()
    }
    
    private func saveImage(){
        if mainPhotoImageView.image == self.plusImage {
            presentAlertWithTitle(
                title: "No photos",
                message: "Please, choose a photo",
                options: "OK"
            ) { (option) in
                switch(option) {
                case "OK":
                    break
                default:
                    break
                }
            }
        } else {
            addNewImage()
            presentAlertWithTitle(
                title: "Success",
                message: "Photo is uploaded",
                options: "OK"
            ) { (option) in
                switch(option) {
                case "OK":
                    self.moveToPreviousViewController()
                    break
                default:
                    break
                }
            }
        }
    }
    
    private func likePhoto() {
        isLiked.toggle()
        
        if isLiked {
            likeButton.setImage(.filledHeart, for: .normal)
        } else {
            likeButton.setImage(.heart, for: .normal)
        }
    }
}

//MARK: - Extensions
extension AddingImageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentTextField.resignFirstResponder()
        return true
    }
}

extension AddingImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.mainPhotoImageView.image = pickedImage
        }
        picker.dismiss(animated: true)
    }
}
