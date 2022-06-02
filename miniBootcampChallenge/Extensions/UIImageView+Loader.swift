//
//  UIImageView+Loader.swift
//  miniBootcampChallenge
//
//  Created by Alejandro Lopez Gomez on 01/06/22.
//

import UIKit

extension UIImageView {
    
    func showLoader(style: UIActivityIndicatorView.Style = .medium) {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        addSubview(indicator)
        indicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    func stopLoader() {
        let indicator = subviews.filter { view in
            guard let _ = view as? UIActivityIndicatorView else { return false }
            return true
        }.first as? UIActivityIndicatorView
        
        indicator?.stopAnimating()
        indicator?.removeFromSuperview()
    }
}
