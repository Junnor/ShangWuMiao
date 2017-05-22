//
//  SoldTicketViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import MJRefresh

class SoldTicketViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.contentInset =  UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "已购票的漫展"
        
        // set navigation bar
        customizeBackItem()

        // refresh
        let headerHandler = #selector(loadTicketExhibition)
        
        let headerRefresh = MJRefreshNormalHeader(refreshingTarget: self,
                                                  refreshingAction: headerHandler)
        headerRefresh?.ignoredScrollViewContentInsetTop = -35
        tableView?.mj_header = headerRefresh
        tableView?.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView?.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ticket order" {
            if let desvc = segue.destination as? ExhibitionTicketTableViewController {
                let indexPath = tableView.indexPathForSelectedRow
                let ex = exhibitions[indexPath!.row]
                desvc.exhibition = ex
            }
        }
    }
    
    private let exhibition = Exhibition()
    private var exhibitions = [Exhibition]()
    @objc private func loadTicketExhibition() {
        exhibition.requestSoldTicketForExhibitionList(loadMore: false, completionHandler: { [weak self] success, info, exhibitions in
            self?.tableView.mj_header.endRefreshing()
            if success {
                if self != nil {
                    self!.exhibitions = exhibitions
                    self!.tableView.reloadData()
                    
                    if exhibitions.count >= kDefaultCount {
                        let footerRefresh = MJRefreshAutoNormalFooter(refreshingTarget: self,
                                                                      refreshingAction: #selector(self!.loadMore))
                        footerRefresh?.setTitle("已全部加载", for: .noMoreData)
                        self!.tableView?.mj_footer = footerRefresh
                    }
                }
            } else {
                print("load exhibition ticket failure: \(info ?? "no value")")
            }
        })
    }
    
    
    @objc private func loadMore() {
        exhibition.requestSoldTicketForExhibitionList(loadMore: true, completionHandler: { [weak self] success, info, exhibitions in
            self?.tableView.mj_footer.endRefreshing()
            if success {
                if self != nil {
                    self!.exhibitions = exhibitions
                    self!.tableView.reloadData()
                }
            } else {
                print("load more exhibition ticket failure: \(info ?? "no value")")
            }
        })
    }
    
    // MARK: - Helper
    
    private let ticketIdnetifer = "bought ticket identififer"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exhibitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ticketIdnetifer, for: indexPath)
        if let cell = cell as? BoughtTicketCell {
            let ex = self.exhibitions[indexPath.row]
            cell.statusLabel?.text = ex.stauts
            cell.titleLabel?.text = ex.name
        }
        return cell
    }

}
