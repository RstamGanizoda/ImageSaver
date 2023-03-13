import Foundation
import UIKit

//MARK: - Classes
final class User: Codable {
    
    //MARK: - let/var
    static let shared = User(username: "", password: "")
    let username: String?
    let password: String?
    var photos : [Image]?
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
        photos = []
    }
}

final class Image: Codable {
    
    //MARK: - let/var
    let imageName: String
    var comment: String?
    var isLiked = false
    
    init(imageName: String, comment: String?, isLiked: Bool = false) {
        self.imageName = imageName
        self.isLiked = isLiked
        self.comment = comment
    }
}
