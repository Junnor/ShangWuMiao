//
//  ExhibitionViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/8.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import Kingfisher
import MJRefresh

class ExhibitionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let comicCellId = "ComicCellIdentifer"
    private let segueIdentifier = "show exhibition"
    
    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // not elegant
        let itemAppearance = UIBarButtonItem.appearance()
        itemAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -100, vertical: -100), for: .default)
        
        // collection view
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = CGSize(width: view.bounds.width, height: 120)
        layout?.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout!
        
        // refresh
        let headerHandler = #selector(loadExhibition)
        let headerRefresh = MJRefreshNormalHeader(refreshingTarget: self,
                                                  refreshingAction: headerHandler)

        collectionView?.mj_header = headerRefresh
        collectionView?.mj_header.beginRefreshing()
    }
    
    private let exhibition = Exhibition()
    private var exhibitions = [Exhibition]()
    
    // MARK: - Navigation
    
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
        exhibition.requestExhibitionList(withKeyword: nil, loadMore: false, completionHandler: { [weak self] success, info, exhibitions in
            self?.collectionView.mj_header.endRefreshing()
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
            } else {
                print("load exhibition failure: \(info)")
            }
        })
    }
    
    
    @objc private func loadMore() {
        exhibition.requestExhibitionList(withKeyword: nil, loadMore: true, completionHandler: { [weak self] success, info, exhibitions in
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: comicCellId, for: indexPath)
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
