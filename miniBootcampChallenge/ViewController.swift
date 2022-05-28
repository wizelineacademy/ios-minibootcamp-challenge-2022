//
//  ViewController.swift
//  miniBootcampChallenge
//

import UIKit

class ViewController: UICollectionViewController {
    
    private struct Constants {
        static let title = "Mini Bootcamp Challenge"
        static let cellID = "imageCell"
        static let cellSpacing: CGFloat = 1
        static let columns: CGFloat = 3
        static var cellSize: CGFloat?
    }
    
    lazy var urls: [URL] = URLProvider.urls
    let activityView = UIActivityIndicatorView(style: .large)
    var fetchedImages:[URL:UIImage] = [:]
    let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
    }
    // Used viewDidAppear to show the activity indicator because with the willAppear and DidLoad didn't work well
    override func viewDidAppear(_ animated: Bool) {
        showActivityIndicatory()
        waitDownload()
    }
    private func showActivityIndicatory() {
       activityView.center = self.view.center
       self.view.addSubview(activityView)
       activityView.startAnimating()
    }
    

}


// TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way
private func fethImage(url:URL, completion: @escaping(UIImage?)->Void) {
    URLSession.shared.dataTask(with: url) { (data,response,error) in
        
        if error != nil && data == nil {
            print(error as Any)
            return
        }
        
        let image = UIImage(data: (data as Data?)!)
        
        DispatchQueue.main.async {
            completion(image)
        }
        
        
    }.resume()
}
// TODO: 2.- Implement a function that allows to fill the collection view only when all photos have been downloaded, adding an animation for waiting the completion of the task.
extension ViewController {
    private func waitDownload() {
        
        for url in urls {
            self.group.enter()
            fethImage(url: url, completion: { image in
                self.fetchedImages[url] = image
                self.group.leave()
            })
        }
        group.notify(queue: .main) {
            print(self.fetchedImages)
            self.activityView.stopAnimating()
            self.collectionView.reloadData()
            
        }
    }
}


// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        urls.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        
        let url = urls[indexPath.row]
        
//        fethImage(url: url) { image in
//            cell.display(image)
//        }
        
        cell.display(self.fetchedImages[url])
        
        return cell
    }
}


// MARK: - UICollectionView FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Constants.cellSize == nil {
          let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (Constants.columns * Constants.cellSpacing - 1)
            Constants.cellSize = (view.frame.size.width - emptySpace) / Constants.columns
        }
        return CGSize(width: Constants.cellSize!, height: Constants.cellSize!)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }
}
