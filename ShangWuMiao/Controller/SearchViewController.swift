//
//  SearchViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/8.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import MJRefresh
import Kingfisher
import SVProgressHUD

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cancelItem: UIBarButtonItem!
    // MARK: - Private properties
    private let exhibitionCellId = "ExhibitionSearchCellIdentifer"
    private let segueIdentifier = "show search exhibition"
    
    private let exhibition = Exhibition()
    fileprivate var exhibitions = [Exhibition]()
    
    fileprivate lazy var shadowView: UIView! = {
        let shadow = UIView(frame: self.view.bounds)
        shadow.isHidden = true
        shadow.backgroundColor = UIColor.background
        shadow.alpha = 0.7
        shadow.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(tapGesture)))
        self.view.insertSubview(shadow, aboveSubview: self.collectionView)

        return shadow
    }()
    
    @objc private func tapGesture() {
        self.searchBar.resignFirstResponder()
        closeShadowView()
    }
    
    @objc private func fireShadowView() {
        shadowView.isHidden = false
    }
    
    @objc private func closeShadowView() {
        shadowView.isHidden = true
    }

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fireShadowView),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closeShadowView),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        // layout
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = CGSize(width: view.bounds.width, height: 120)
        layout?.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout!

        // refresh
        let headerHandler = #selector(loadExhibition)
        let headerRefresh = MJRefreshNormalHeader(refreshingTarget: self,
                                                  refreshingAction: headerHandler)
        
        collectionView?.mj_header = headerRefresh
        
        // Register  for previewing  .... 3D touch
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: collectionView)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private var forword = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if forword {  // only perform once
            forword = false
            
            self.searchBar.becomeFirstResponder()
//            shadowView.isHidden = false
        }
    }

    // MARK: - Navigation
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.searchBar.resignFirstResponder()
        
        dismiss(animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            if let desvc = segue.destination as? ExhibitionDetailViewController,
                let indexPath = collectionView.indexPathsForSelectedItems?.first {
                let ex = exhibitions[indexPath.item]
                desvc.exhibition = ex
            }
        }
    }
    
    // MARK: - Helper
    @objc private func loadExhibition() {
        exhibition.requestExhibitionList(withKeyword: self.searchBar.text,
                                         loadMore: false,
                                         completionHandler: { [weak self] success, info, exhibitions in
                                            self?.collectionView.mj_header.endRefreshing()
                                            if info != "" {
                                                SVProgressHUD.showInfo(withStatus: info)
                                            }
                                            if success {
                                                if self != nil {
                                                    self!.exhibitions = exhibitions
                                                    self!.collectionView.reloadData()
                                                    if exhibitions.count >= kDefaultCount {
                                                        let footerRefresh = MJRefreshAutoNormalFooter(refreshingTarget: self,
                                                                      refreshingAction: #selector(self!.loadMore))
                                                        footerRefresh?.setTitle("已全部加载", for: .noMoreData)
                                                        self!.collectionView?.mj_footer = footerRefresh
                                                    }
                                                }
                                            }
        })
    }
    
    
    @objc private func loadMore() {
        exhibition.requestExhibitionList(withKeyword: self.searchBar.text,
                                         loadMore: true,
                                         completionHandler: { [weak self] success, info, exhibitions in
            self?.collectionView.mj_footer.endRefreshing()
            if success {
                if self != nil {
                    self!.exhibitions = exhibitions
                    self!.collectionView.reloadData()
                }
            } else {
                print("load more exhibition failure: \(info)")
            }
        })
    }
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.exhibitions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: exhibitionCellId, for: indexPath)
        if let cell = cell as? ComicViewCell {
            let ex = self.exhibitions[indexPath.item]
            
            if let url = URL(string: kImageHeaderUrl + ex.cover!) {
                let resourcce = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
                cell.comicImageView.kf.setImage(with: resourcce,
                                                placeholder: nil,
                                                options: [.transition(.fade(1))],
                                                progressBlock: nil,
                                                completionHandler: nil)
            }
            cell.titleLabel?.text = ex.name
            let startTime = ex.exhibition(stringTime: ex.start_time, digit: false)
            let endTime = ex.exhibition(stringTime: ex.end_time, digit: false)
            cell.dateLabel?.text = "\(startTime) - \(endTime)"
            cell.addressLabel?.text = ex.addr
        }
        return cell
    }
}

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        self.collectionView.mj_header.beginRefreshing()
    }
}

extension SearchViewController: ExhibitionPreviewable {
    var sourePreViewController: UIViewController {
        return self
    }
}

extension SearchViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = collectionView.indexPathForItem(at: location),
            let cell = collectionView.cellForItem(at: indexPath) else {
                return nil
        }
        
        guard let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExhibitionDetailViewController") as? ExhibitionDetailViewController else {
            return nil
        }
        
        let exData = exhibitions[indexPath.item]
        detailViewController.exhibition = exData
        detailViewController.previewSourceViewController = self
        
        if #available(iOS 9.0, *) {
            previewingContext.sourceRect = cell.frame
        } else {
            // Fallback on earlier versions
        }
        
        return detailViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: nil)
    }
}
