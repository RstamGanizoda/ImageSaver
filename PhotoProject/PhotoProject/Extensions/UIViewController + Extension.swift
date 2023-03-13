import Foundation
import UIKit

//MARK: - Extensions
extension UIViewController{
    
    func presentAlertWithTitle(
        title: String?,
        message: String?,
        options: String...,
        completion: @escaping (String) -> Void) {
           
           let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
           )
           for (index, option) in options.enumerated() {
               alert.addAction(UIAlertAction.init(
                title: option,
                style: .default,
                handler: { (action) in
                   completion(options[index])
               }))
           }
           self.present(alert, animated: true)
       }
}
