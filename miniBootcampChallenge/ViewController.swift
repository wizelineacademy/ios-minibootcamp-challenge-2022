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
    private var images: [UIImage] = []
    private var isDownloading: Bool = true
    private var group = DispatchGroup()
    private var uiActivityIndicator = UIActivityIndicatorView(style: .medium)
    private lazy var urls: [URL] = URLProvider.urls
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        setUpUI()
        refresh()
    }
    
    func setUpUI(){
        uiActivityIndicator.center = view.center
        view.addSubview(uiActivityIndicator)
        checkIfShowDisplayLoaderIndicator()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.beginRefreshing()
        collectionView.refreshControl = refreshControl
        collectionView.sendSubviewToBack(refreshControl)
    }
    
    private func checkIfShowDisplayLoaderIndicator(){
        if isDownloading {
            uiActivityIndicator.startAnimating()
        }
        else {
            uiActivityIndicator.stopAnimating()
        }
    }
    
   @objc func refresh() {
        var arrayOfImages: [UIImage] = []

        urls.forEach { result in
            self.group.enter()
            downloadImage(url: result, completion: { image in
                print("*** resulto una imagen")
                arrayOfImages.append(image)
                self.group.leave()
                
            })
        }

        group.notify(queue: .main) {
            self.images = arrayOfImages
            self.collectionView.reloadData()
            self.didRefresh()
        }
    }
    // TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way
    func downloadImage(url: URL, completion: @escaping(UIImage)->Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                   completion(image)
               } else if let error = error {
                   print("*** error \(error)")
               }
            }
        }.resume()
    }
    
    // TODO: 2.- Implement a function that allows to fill the collection view only when all photos have been downloaded, adding an animation for waiting the completion of the task.
    private func didRefresh() {
        isDownloading = false
        checkIfShowDisplayLoaderIndicator()
        guard let refreshControl = collectionView.refreshControl else { return }
        refreshControl.endRefreshing()
    }
}

// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("*** \(images.count) ")
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        cell.display(images[indexPath.row])
        
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
