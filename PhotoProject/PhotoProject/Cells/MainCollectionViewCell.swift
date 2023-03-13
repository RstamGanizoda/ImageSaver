import UIKit

//MARK: - classes
class MainCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var mainImageView: UIImageView!

    //MARK: - let/var
    static let identifier = "MainCollectionViewCell"
    
    //MARK: - functionality
    func configureImages(image: UIImage?) {
        self.mainImageView.contentMode = .scaleAspectFill
        self.mainImageView.image = image
    }
}
