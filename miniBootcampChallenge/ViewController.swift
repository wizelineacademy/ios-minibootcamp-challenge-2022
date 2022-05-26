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
    
    private let urls: [URL] = URLProvider.urls
    private var images: [UIImage] = []
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        collectionView.addSubview(refreshControl)
        
        refresh()
    }
}

// MARK: - Targets
extension ViewController {
    @objc func refresh() {
        refreshControl.beginRefreshing()
        fetchImages { [weak self] images in
            DispatchQueue.main.async {
                self?.images = images
                self?.collectionView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
    }
}

// MARK - Helpers
extension ViewController {
    private func fetchImages(completion: @escaping ([UIImage]) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            completion(
                self?.urls.map { url -> UIImage in
                    do { return UIImage(data: try Data(contentsOf: url)) ?? UIImage() }
                    catch { return UIImage() }
                } ?? []
            )
        }
    }
}

// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.refreshControl.isRefreshing ? 0 : images.count
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
