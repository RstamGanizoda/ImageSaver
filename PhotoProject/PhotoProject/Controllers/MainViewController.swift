import UIKit

//MARK: - Extension
private extension CGFloat {
    static let space = 5.0
    static let cornerRadius = CGFloat(20)
    static let alphaForBackground = CGFloat(0.15)
}

private extension Int {
    static let horisontalCount = 3
}

//MARK: - Classes
class MainViewController: UIViewController, AddingImageViewControllerDelegate, EdittingViewControllerDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    //MARK: - let/var
    var username: String?
    let addingImageViewController = "AddingImageViewController"
    let edittingViewController = "EdittingViewController"
    let storageManager = StorageManager.shared
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addAllUI()
        loadUsername()
    }
    
    //MARK: - IBAction
    @IBAction func addButtonPressed(_ sender: UIButton) {
        createAddingImageViewController()
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        moveToPreviousVC()
    }
    
    //MARK: - Navigation
    private func createAddingImageViewController(){
        guard let controller = self.storyboard?
            .instantiateViewController(withIdentifier: addingImageViewController) as? AddingImageViewController else {
            return
        }
        controller.delegate = self
        self.navigationController?
            .pushViewController(
                controller,
                animated: true)
    }
    
    private func moveToPreviousVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func createEdittingViewController(
        image: UIImage?,
        comment: String?,
        isLiked: Bool?,
        imageName: String?,
        index: Int
    ) {
        guard let controller = self.storyboard?
            .instantiateViewController(withIdentifier: edittingViewController) as? EdittingViewController else {
            return
        }
        controller.delegate = self
        controller.image = image
        controller.comment = comment ?? ""
        controller.isLiked = isLiked ?? false
        controller.imageName = imageName
        controller.index = index
        self.navigationController?
            .pushViewController(
                controller,
                animated: true)
    }
    
    //MARK: - UI
    private func addAllUI() {
        modifyButtons()
        modifyCollectionView()
    }
    
    private func modifyButtons() {
        backButton.buttonParameters()
        backButton.dropShadow()
        addButton.buttonParameters()
        addButton.dropShadow()
    }
    
    func reloadCollectionView() {
        imagesCollectionView.reloadData()
    }
    
    private func modifyCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = .space / 2
        layout.minimumInteritemSpacing = .zero
        let count = CGFloat(Int.horisontalCount)
        let width = self.imagesCollectionView.frame.size.width
        let side = (width / count) - .space
        layout.itemSize = CGSize(
            width: side,
            height: side
        )
        imagesCollectionView.layer.cornerRadius = .cornerRadius
        imagesCollectionView.setCollectionViewLayout(layout, animated: true)
        imagesCollectionView.contentInset = UIEdgeInsets(
            top: .zero,
            left: .space,
            bottom: .space,
            right: .space
        )
        imagesCollectionView.isOpaque = false
        imagesCollectionView.backgroundColor = .white.withAlphaComponent(.alphaForBackground)
    }
    
    //MARK: - Functionality
    private func loadUsername() {
        if let unwrappedUsername = username {
            usernameLabel.text = "Welcome, \(unwrappedUsername)"
        } else {
            usernameLabel.text = "Welcome guest"
        }
    }
    
    func EdittingViewControllerDidDeleteImage(at index: Int) {
        var images = storageManager.getImages() ?? []
        guard index < images.count else { return }
        let imageNameToDelete = images[index].imageName
        images.remove(at: index)
        storageManager.saveImages(photo: images)
        imagesCollectionView.reloadData()
    }
}
//MARK: - Extensions
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let allData = StorageManager.shared.getImages()
        let cellCount = allData?.count
        return cellCount ?? .zero
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(
                withReuseIdentifier: MainCollectionViewCell.identifier,
                for: indexPath
            ) as? MainCollectionViewCell else { return UICollectionViewCell() }
        
        guard let images = storageManager.getImages(),
              indexPath.item < images.count else { return UICollectionViewCell() }
        let image = storageManager.loadImage(fileName: images[indexPath.item].imageName)
        cell.configureImages(image: image)
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let images = storageManager.getImages(),
              indexPath.item < images.count else { return }
        
        let image = storageManager.loadImage(fileName: images[indexPath.item].imageName)
        let imageName = images[indexPath.item].imageName
        let savedData = storageManager.getImages()
        let comment = savedData?[indexPath.item].comment
        let isLiked = savedData?[indexPath.item].isLiked
        let index = indexPath.item
        createEdittingViewController(
            image: image,
            comment: comment,
            isLiked: isLiked,
            imageName: imageName,
            index: index
        )
    }
}
