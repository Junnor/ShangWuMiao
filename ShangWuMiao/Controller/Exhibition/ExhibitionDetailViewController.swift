//
//  ExhibitionDetailViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/8.
//  Copyright © 2017年 moelove. All rights reserved.
//
// colection view 的选择处理一团糟

import UIKit
import Kingfisher
import SVProgressHUD
import EventKit

class ExhibitionDetailViewController: UIViewController {
    
    /// MARK: - For Share
    var shareView: UIView!
    let shareViewHeight: CGFloat = 400
    
    lazy var shareShadowView: UIView = {
        let shadowView = UIView()
        shadowView.frame = self.view.frame
        shadowView.backgroundColor = UIColor(white: 0, alpha: 0)
        shadowView.isHidden = true
        shadowView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                               action: #selector(dismissShareView)))
        
        return shadowView
    }()
    
    private func comfigureRightBarButtonItem() {
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ico-share"),
                                   style: .done,
                                   target: self,
                                   action: #selector(showShareView))
        navigationItem.rightBarButtonItem = item
    }
    
    private func configureShareView() {
        let shareViewController = ShareViewController(nibName: "ShareViewController", bundle: nil)
        shareViewController.delegate = self
        self.addChildViewController(shareViewController)
        let rect = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: shareViewHeight)
        shareViewController.view.frame = rect
        self.view.addSubview(shareViewController.view)
        shareViewController.didMove(toParentViewController: self)
        
        shareView = shareViewController.view
    }
    
    /// MARK: - For 3D Touch previewing
    weak var previewSourceViewController: ExhibitionPreviewable!
    
    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        let preview = UIPreviewAction(title: "查看", style: .default) { [weak self] (previewAction, viewController) in
            if let sourceVC = self?.previewSourceViewController {
                guard let detailViewController = UIStoryboard(name: UIStoryboard.Exhibition, bundle: nil).instantiateViewController(withIdentifier: "ExhibitionDetailViewController") as? ExhibitionDetailViewController else {
                    return
                }
                // DO NOT perform sourceVC.sourePreViewController.show(self, sender: self)
                // Because self is dismissed before perfome sourceVC.sourePreViewController.show(::)
                detailViewController.exhibition = self?.exhibition
                sourceVC.sourePreViewController.show(detailViewController, sender: self)
            }
        }
        
        return [preview]
    }
    
    /// MARK: - Outlets
    @IBOutlet weak var payView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var vcpriceLabel: UILabel!
    
    /**
     dsdd
     */
    @IBOutlet weak var payViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = UIColor.background
            collectionView.showsVerticalScrollIndicator = false
            collectionView.alwaysBounceVertical = true
        }
    }
 
    
    /// MARK: - Public property set from segue
    var exhibition: Exhibition!
    
    /// MARK: - Private properties
    fileprivate var isVendor: Bool = true
    fileprivate var constCellCounts: Int {
        return isVendor ? 4 : 3
    }
    
    fileprivate var tickts = [Ticket]()
    fileprivate var blurView: ExBlurView!
    fileprivate var layerBlurView = false
    
    fileprivate let limitLines = 6
    fileprivate let showMoreButtonWithGap: CGFloat = 50
    fileprivate let noMoreButtonWithGap: CGFloat = 20
    fileprivate let limitTextHeight: CGFloat = 170   // (limitetLines * 20 + 50 gap)
    fileprivate var readMore = false
    fileprivate var originalPrice = true
    fileprivate var lastSelectedIndexPath = IndexPath(item: 0, section: 1)
    
    // observer ticktsTimes & ticktPrice
    fileprivate var ticktsTimes = 1 {
        didSet {
            if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                //                let money = originalPrice ?
                //                    self.tickts[indexPath.item].price : self.tickts[indexPath.item].proxy_price
                let money = self.tickts[indexPath.item].proxy_price
                self.vcpriceLabel?.text = "\(Float(money!)! * Float(self.ticktsTimes))"
                
                self.ticktsTimesLabel?.text = "\(ticktsTimes)"
            }
        }
    }
    fileprivate var ticktPrice: Float! {
        didSet {
            if ticktPrice != nil {
                self.vcpriceLabel?.text = "\(ticktPrice * Float(self.ticktsTimes))"
            }
        }
    }
    
    fileprivate weak var phoneTextField: UITextField!
    fileprivate weak var ticktsTimesLabel: UILabel!
    
    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel?.text = self.exhibition.name
        self.titleLabel?.isHidden = true
        
        self.view.addSubview(shareShadowView)
        
        
        registerCollectionView()
        blurView = ExBlurView.blurViewFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // keyboard notification
        NotificationCenter.default.addObserver(self.collectionView,
                                               selector: #selector(self.collectionView.nyato_keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
        isVendor = (User.shared.vendorType != Vendor.none)
        
        if self.isVendor {
            loadExhibitionData()
        } else {
            self.payViewHeightConstraint.constant = 0
            payView.isHidden = true
        }
        
        comfigureRightBarButtonItem()
        configureShareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !useDefaultImage {
            if currentBarTintColor != nil {
                let image = UIImage.from(color: currentBarTintColor)
                self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
                self.navigationController?.navigationBar.shadowImage = image
            } else {
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helper
    
    @objc private func tapAction() {
        self.phoneTextField?.resignFirstResponder()
    }
    
    private func loadExhibitionData() {
        exhibition.requestExhibitionListTickets { [weak self] (success, info, tickts) in
            if success {
                self?.tickts = tickts
                self?.collectionView.reloadData()
                
                // selection style
                let indexPath = IndexPath(item: 0, section: 1)
                self?.collectionView.selectItem(at: indexPath,
                                                animated: true,
                                                scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
                
                // set initial value
                self?.vcpriceLabel?.text = self?.tickts[0].proxy_price
            } else {
                printX("request exhibition ticket failure: \(String(describing: info))")
            }
        }
    }
    
    private func registerCollectionView() {
        collectionView.register(UINib(nibName: "ExHeaderCell", bundle: nil), forCellWithReuseIdentifier: "ExHeaderCellID")
        collectionView.register(UINib(nibName: "ExDescriptionCell", bundle: nil), forCellWithReuseIdentifier: "ExDescriptionCellID")
        collectionView.register(UINib(nibName: "ExAddressCell", bundle: nil), forCellWithReuseIdentifier: "ExAddressCellID")
        collectionView.register(UINib(nibName: "ExInputHintCell", bundle: nil), forCellWithReuseIdentifier: "ExInputHintCellID")
        collectionView.register(UINib(nibName: "ExTicketCell", bundle: nil), forCellWithReuseIdentifier: "ExTicketCellID")
        
        collectionView.register(UINib(nibName: "ExFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "ExFooterViewID")
    }
    
    @objc fileprivate func textFieldResignFirstResonder() {
        phoneTextField?.resignFirstResponder()
    }
    
    @IBAction func buy(_ sender: Any) {
        let result = nyato_isPhoneNumber(phoneNumber: self.phoneTextField.text)
        if result.info != nil {
            SVProgressHUD.showInfo(withStatus: result.info!)
        } else {
            if let price = Float((vcpriceLabel?.text)!) {
                let message = "确认购买门票？\n [请确认手机号码 \(self.phoneTextField.text!) 无误] \n\n 数量：\(ticktsTimes) \n\n 总价：\(price)"
                let alert = UIAlertController(title: "确认购买", message: message, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
                let ok = UIAlertAction(title: "确定", style: .destructive) { [weak self] _ in
                    if User.shared.mcoins >= price {    // Buy tickts directly
                        if self != nil {
                            let tickt = self?.tickts[(self?.lastSelectedIndexPath.item)!]
                            User.buyTickt(ticktId: Int(tickt!.id)!,
                                          counts: (self?.ticktsTimes)!,
                                          phone: (self?.phoneTextField.text!)!,
                                          price: price,
                                          callBack: { success, info in
                                            if success {
                                                countlyWithMoney(Double(price))
                                                
                                                // 更新金额
                                                User.requestUserInfo(completionHandler: { (success, statusInfo) in
                                                    if success {
                                                        // TODO
                                                    } else {
                                                        SVProgressHUD.showInfo(withStatus: statusInfo)
                                                        printX("request user info failure: \(String(describing: statusInfo))")
                                                    }
                                                })
                                                
                                                // 页面跳转
                                                if let ticktsvc = self?.storyboard?.instantiateViewController(withIdentifier: "SoldTicketViewController") as? SoldTicketViewController {
                                                    self?.navigationController?.pushViewController(ticktsvc, animated: true)
                                                }
                                                SVProgressHUD.showSuccess(withStatus: info)
                                            } else {
                                                SVProgressHUD.showError(withStatus: info)
                                            }
                            })
                        }
                    } else {     // Due to has not enough mcoins, top up
                        if let topupvc = self?.storyboard?.instantiateViewController(withIdentifier: "TopupViewController") as? TopupViewController {
                            self?.navigationController?.pushViewController(topupvc, animated: true)
                        }
                    }
                }
                alert.addAction(cancel)
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    // set navigation bar
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        // for navi bar
        naviBarTintColorWith(offsetY: offsetY)
        
        // for blur view
        var transform = CATransform3DIdentity
        if offsetY < 0 {
            let scale = -(offsetY * 2) / self.blurView.bounds.size.height;
            transform = CATransform3DTranslate(transform, 0, offsetY, 0);
            transform = CATransform3DScale(transform, 1.0 + scale, 1.0 + scale, 0);
            self.blurView.layer.transform = transform;
        }
    }
    
    private var useDefaultImage = false
    private var currentBarTintColor: UIColor!
    private func naviBarTintColorWith(offsetY: CGFloat) {
        if offsetY >= 0 {
            let alpha = min(offsetY / 64, 1.0)
            let color = UIColor.naviBarTintColor(alpha: alpha)
            
            currentBarTintColor = color
            
            self.titleLabel?.alpha = alpha
            self.titleLabel?.isHidden = false
            
            if offsetY >= 64 {
                useDefaultImage = true
                self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
                self.navigationController?.navigationBar.shadowImage = nil
            } else {
                useDefaultImage = false
                let image = UIImage.from(color: color)
                self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
                self.navigationController?.navigationBar.shadowImage = image
            }
        }
    }
    
}


// MARK: - Collection view datasource
extension ExhibitionDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.isVendor ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? constCellCounts : tickts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExHeaderCellID", for: indexPath)
                if let cell = cell as? ExHeaderCell {
                    if let url = URL(string: kImageHeaderUrl + self.exhibition.cover!) {
                        let resourcce = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
                        cell.exImageView.kf.setImage(with: resourcce,
                                                     placeholder: nil,
                                                     options: [.transition(.fade(1))],
                                                     progressBlock: nil,
                                                     completionHandler: nil)
                        
                        blurView.blurImageView.kf.setImage(with: resourcce)
                    }
                    
                    cell.nameLabel.text = self.exhibition.name
                    cell.presaleLabel.text = self.exhibition.presale_price
                    cell.locationLabel.text = self.exhibition.location
                    
                    let attributedText = NSMutableAttributedString(string: self.exhibition.scene_price)
                    attributedText.addAttributes([NSBaselineOffsetAttributeName:0, NSStrikethroughStyleAttributeName: 1], range: NSRange(location: 0, length: NSString(string: self.exhibition.scene_price).length))
                    cell.scenePriceLabel.attributedText = attributedText
                    
                    let startTime = exhibition.exhibition(stringTime: self.exhibition.start_time, digit: true)
                    let endTime = exhibition.exhibition(stringTime: self.exhibition.end_time, digit: true)
                    
                    cell.timeLabel.text = "\(startTime) - \(endTime)"
                    
                    // blur view
                    if !self.layerBlurView {
                        self.layerBlurView = true
                        
                        self.blurView.frame = cell.frame;
                        self.blurView.layer.zPosition = -1
                        self.collectionView.insertSubview(self.blurView, at: 0)
                    }
                }
                
                return cell
            } else if indexPath.item == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExDescriptionCellID", for: indexPath)
                cell.backgroundColor = UIColor.white
                if let cell = cell as? ExDescriptionCell {
                    cell.titleLabel.text = self.exhibition.exDescription
                    
                    if shouldShowMoreButton() {
                        cell.moreButton.addTarget(self, action: #selector(moreWords), for: .touchUpInside)
                        cell.moreButton.setTitle(readMore ? "点击收起" : "展开更多", for: .normal)
                        cell.titleLabel.numberOfLines = readMore ? 0 : limitLines
                    } else {
                        cell.moreButton.isHidden = true
                        cell.bottonConstraint.constant = 8
                    }
                    
                }
                return cell
            } else if indexPath.item == 2 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExAddressCellID", for: indexPath)
                cell.backgroundColor = UIColor.background
                if let cell = cell as? ExAddressCell {
                    cell.titleLabel.text = "漫展详细地址：" + self.exhibition.addr
                }
                
                return cell
            } else {   // Won't show if user not vendor
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExInputHintCellID", for: indexPath)
                cell.backgroundColor = UIColor.white
                if let cell = cell as? ExInputHintCell {
                    self.phoneTextField = cell.phoneTextField   // weak
                    
                    cell.priceButton.addTarget(self, action: #selector(priceChangeAction(sender:)), for: .touchUpInside)
                    cell.priceButton.setTitle(originalPrice ? "显示代理价格" : "返回原价", for: .normal)
                    if originalPrice {
                        cell.priceButton.backgroundColor = UIColor.background
                        cell.priceButton.layer.borderWidth = 1.0
                        cell.priceButton.layer.borderColor = UIColor.themeRed.cgColor
                        cell.priceButton.setTitleColor(UIColor.themeRed, for: .normal)
                    } else {
                        cell.priceButton.backgroundColor = UIColor.themeRed
                        cell.priceButton.setTitleColor(UIColor.white, for: .normal)
                    }
                }
                
                return cell
            }
        } else  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExTicketCellID", for: indexPath)
            if let cell = cell as? ExTicketCell {
                if tickts.count >= 1 {
                    let tickt = tickts[indexPath.item]
                    cell.nameLabel?.text = tickt.name
                    cell.priceLabel?.text = originalPrice ? tickt.price : tickt.proxy_price
                    
                    cell.layer.borderWidth = 1.0
                    cell.layer.borderColor = UIColor.themeRed.cgColor
                    
                    if cell.isSelected {
                        cell.nameLabel?.textColor = UIColor.white
                        cell.priceLabel?.textColor = UIColor.white
                        cell.backgroundColor = UIColor.themeRed
                        
                        //                        self.ticktPrice = Float(cell.priceLabel.text!)!
                        self.ticktPrice = Float(tickt.proxy_price)!
                        
                    } else {
                        cell.nameLabel?.textColor = UIColor.themeRed
                        cell.priceLabel?.textColor = UIColor.themeRed
                        cell.backgroundColor = UIColor.background
                    }
                    
                    if !originalPrice && !cell.isSelected {
                        cell.priceLabel?.textColor = UIColor.themeYellow
                    }
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "ExFooterViewID", for: indexPath)
        
        if let footer = footerView as? ExFooterView, indexPath.section == 1 {
            footer.plusButton.addTarget(self, action: #selector(plusAction), for: .touchUpInside)
            footer.minusButton.addTarget(self, action: #selector(minusAction), for: .touchUpInside)
            
            // weak
            self.ticktsTimesLabel = footer.sumLabel
        }
        return footerView
    }
    
    fileprivate func shouldShowMoreButton() -> Bool {
        let font = UIFont.systemFont(ofSize: 16)
        let str = self.exhibition.exDescription!
        return heightForText(text: str,
                             font: font,
                             width: collectionView.bounds.width - 30) + 40 > limitTextHeight
    }
    
    @objc private func moreWords() {
        self.readMore = !self.readMore
        
        // just reload the specific indexPath
        self.collectionView.reloadItems(at: [IndexPath(item: 1, section: 0)])
    }
    
    @objc private func plusAction() {
        ticktsTimes += 1
    }
    
    @objc private func minusAction() {
        if ticktsTimes == 1 {
            return
        }
        ticktsTimes -= 1
    }
    
    @objc private func priceChangeAction(sender: UIButton) {
        originalPrice = !originalPrice
        
        let lastSelectedIndex = collectionView.indexPathsForSelectedItems?.first
        
        self.collectionView.reloadData()
        
        self.collectionView.selectItem(at: lastSelectedIndex, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
    }
}

// MARK: - Collection view delegate flow layout
extension ExhibitionDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ExTicketCell {
            cell.nameLabel?.textColor = UIColor.white
            cell.priceLabel?.textColor = UIColor.white
            cell.backgroundColor = UIColor.themeRed
            
            // for tickts count
            ticktsTimes = (lastSelectedIndexPath == indexPath) ? ticktsTimes : 1
            lastSelectedIndexPath = indexPath
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ExTicketCell {
            cell.nameLabel?.textColor = UIColor.themeRed
            cell.priceLabel?.textColor = UIColor.themeRed
            cell.backgroundColor = UIColor.background
            
            if !originalPrice {
                cell.priceLabel?.textColor = UIColor.themeYellow
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return section == 0 ? UIEdgeInsets.zero : UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? 0 : 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return section == 0 ? CGSize.zero : CGSize(width: collectionView.bounds.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.bounds.width
        var height: CGFloat = 0.0
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                height = UIScreen.main.bounds.height * 2/5
            case 1:
                let font = UIFont.systemFont(ofSize: 16)
                let str = self.exhibition.exDescription!
                var tmpHeight = heightForText(text: str, font: font, width: width - 30)
                
                if shouldShowMoreButton() {
                    tmpHeight += showMoreButtonWithGap
                    height = readMore ? tmpHeight : limitTextHeight
                } else {
                    
                    tmpHeight += noMoreButtonWithGap
                    height = max(tmpHeight, 50)
                }
                
            case 2:
                let font = UIFont.systemFont(ofSize: 16)
                let str = "漫展详细地址：" + self.exhibition.addr
                let tmpHeight = heightForText(text: str, font: font, width: width - 30) + 16
                height = max(tmpHeight, 50)
            default:
                height = 120
                break
            }
        } else {
            width -= 20
            height = 40
        }
        
        return CGSize(width: width, height: height)
    }
    
    fileprivate func heightForText(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: text).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(rect.height)
    }
}
