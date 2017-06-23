//
//  TopupRecordViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/9.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import MJRefresh

class TopupRecordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            // offset the gap when table view style is .group
            tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: -35, right: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "充值记录"
        
        // refresh
        let headerHandler = #selector(loadHistory)
        let headerRefresh = MJRefreshNormalHeader(refreshingTarget: self,
                                                  refreshingAction: headerHandler)
        headerRefresh?.ignoredScrollViewContentInsetTop = -35
        tableView?.mj_header = headerRefresh
        tableView?.mj_header.beginRefreshing()
    }

    private let topup = TopupList()
    private var topupLists = [TopupList]()
    @objc private func loadHistory() {
        topup.requestTopupList(loadMore: false, completionHandler: { [weak self] success, info, topupLists in
            self?.tableView.mj_header.endRefreshing()
            if success {
                if self != nil {
                    self!.topupLists = topupLists
                    self!.tableView.reloadData()
                    
                    if topupLists.count >= kDefaultCount {
                        let footerRefresh = MJRefreshAutoNormalFooter(refreshingTarget: self,
                                                                      refreshingAction: #selector(self!.loadMore))
                        footerRefresh?.setTitle("已全部加载", for: .noMoreData)
                        self!.tableView?.mj_footer = footerRefresh
                    }
                }
            } else {
                printX("load topup list failure: \(info ?? "no value")")
            }
        })
    }
    
    @objc private func loadMore() {
        topup.requestTopupList(loadMore: true, completionHandler: { [weak self] success, info, topupLists in
            self?.tableView.mj_footer.endRefreshing()
            if success {
                if self != nil {
                    self!.topupLists = topupLists
                    self!.tableView.reloadData()
                }
            } else {
                print("load more topup list failure: \(info ?? "no value")")
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topupLists.count
    }
    
    private let listIdentifier = "top up recorder identifier"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: listIdentifier, for: indexPath)
        cell.selectionStyle = .none
        if let cell = cell as? TopupRecordCell {
            let list = topupLists[indexPath.row]
            cell.titleLabel?.text = list.orderTitle
            cell.orderIdLabel?.text = list.orderid
            cell.statusLabel?.text = list.pay_status
            cell.priceLabel?.text = list.order_price
        }
        return cell
    }
    
}
