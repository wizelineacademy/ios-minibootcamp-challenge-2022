//
//  ImageCell.swift
//  miniBootcampChallenge
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func display(_ image: UIImage? = nil) {
        if let image = image {
            imageView.stopLoader()
            imageView.image = image
        } else {
            imageView.showLoader()
        }
    }
}
