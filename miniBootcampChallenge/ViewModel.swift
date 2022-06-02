//
//  ViewModel.swift
//  miniBootcampChallenge
//
//  Created by Alejandro Lopez Gomez on 01/06/22.
//

import UIKit

protocol ViewModelDelegate {
    func didFinishLoadingImages()
}

final class ViewModel {
    
    private(set) var photos: [UIImage] = []
    private(set) lazy var urls: [URL] = URLProvider.urls
    var delegate: ViewModelDelegate?
    
    func fetchImages() {
        var _photos: [UIImage] = []
        DispatchQueue.global().async {
            for (index, imageUrl) in self.urls.enumerated() {
                let data = try? Data(contentsOf: imageUrl)
                if let image = UIImage(data: data!) {
                    _photos.append(image)
                }
                
                if index == self.urls.count - 1 {
                    self.photos = _photos
                }
            }

            self.delegate?.didFinishLoadingImages()
        }
    }
}
