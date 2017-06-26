//
//  TabBarViewController.swift
//  ShangWuMiao
//
//  Created by Ju on 2017/5/8.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD
import Kingfisher

class TabBarViewController: UITabBarController {
    
    var newExhibitionView: NewExhibition!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationConfigure()
        
        // 载入用户信息
        User.requestUserInfo(completionHandler: { [weak self] (success, statusInfo) in
            if success {
                // For home screen quick actions
                UIApplication.shared.keyWindow?.rootViewController = self
            } else {
                SVProgressHUD.showInfo(withStatus: statusInfo)
                printX("request user info failure: \(String(describing: statusInfo))")
            }
        })
        
        // 检测设置信息（获取不同地区手机号的一些信息）
        User.requestSettingInfo()
        
        // New exhibition view
        configureNewExhibitionView()
    }
    
    // MARK: - 本地最新一个漫展相关
    private func configureNewExhibitionView() {
        newExhibitionView = Bundle.main.loadNibNamed("NewExhibition", owner: nil, options: [:])?.first as! NewExhibition
        newExhibitionView.frame = self.view.frame
        newExhibitionView.backgroundColor = UIColor.background
        let tap = UITapGestureRecognizer(target: self, action: #selector(toNewExhibition))
        newExhibitionView.addGestureRecognizer(tap)

        newExhibitionView.timeRemindButton.addTarget(self, action: #selector(skip), for: .touchUpInside)

        Exhibition.newLocalExhibition { (success, exhibition) in
            if success {
                self.newExhibition = exhibition
                self.dataWithNewExhibitionView()
            } else {
                self.newExhibitionView.removeFromSuperview()
            }
        }
    }
    
    private var timer: Timer!
    private var seconds = 7
    
    private func dataWithNewExhibitionView() {
        
        if let url = URL(string: kImageHeaderUrl + newExhibition.logo!) {
            let resourcce = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            newExhibitionView.bgImageView.kf.setImage(with: resourcce,
                                    placeholder: nil,
                                    options: [.transition(.fade(1))],
                                    progressBlock: nil,
                                    completionHandler: nil)
        }
        
        self.view.addSubview(self.newExhibitionView)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateUI),
                                     userInfo: nil,
                                     repeats: true)
        timer?.fire()
    }
    
    @objc private func skip() {
        timer?.invalidate()
        newExhibitionView?.removeFromSuperview()
    }
    
    @objc private func updateUI() {
        newExhibitionView.timeRemindButton.setTitle("跳过 \(seconds) s", for: .normal)

        seconds -= 1
        if seconds == -1 {
            timer?.invalidate()
            newExhibitionView.removeFromSuperview()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        seconds = 7
        timer?.invalidate()
        newExhibitionView.timeRemindButton?.setTitle("", for: .normal)
    }
    
    private var newExhibition: Exhibition!
    @objc private func toNewExhibition() {
        // TODO: segue action
        if let selectedController = self.selectedViewController as? UINavigationController,
            let exhibitionDetailVC = UIStoryboard.exhibition().instantiateViewController(withIdentifier: "ExhibitionDetailViewController") as? ExhibitionDetailViewController {
            exhibitionDetailVC.exhibition = newExhibition
            selectedController.pushViewController(exhibitionDetailVC, animated: true)
        } else {
            timer?.invalidate()
            newExhibitionView.removeFromSuperview()
        }
    }
    
    // MARK: - 定位相关
    private var manager: CLLocationManager!
    
    fileprivate var allArea: NSMutableOrderedSet = []
    //    fileprivate var provinceNames = [String]()
    fileprivate var provinces = [(id: Int, name: String)]()
    //    fileprivate var provinceIds = [Int]()
    
    fileprivate var cityName = ""
    fileprivate var cityID = 0
    fileprivate var procinceName = ""
    fileprivate var provinceId = 0
    fileprivate var longitude = CLLocationDegrees(110.1210)
    fileprivate var latitude = CLLocationDegrees(19.10)
    
    private func locationConfigure() {
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 50
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        if let file = Bundle.main.path(forResource: "Area", ofType: "plist"),
            let erea = NSMutableArray(contentsOfFile: file) {
            allArea = NSMutableOrderedSet(array: erea as [AnyObject])
        }
        
        for area in allArea {
            let dic = area as! Dictionary<String, AnyObject>
            let name = dic["title"] as! String
            let id = dic["province_id"] as! Int
            
            //            provinceNames.append(name)
            //            provinceIds.append(id)
            
            let province = (id: id, name: name)
            provinces.append(province)
        }
    }
    
}

extension TabBarViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            longitude = location.coordinate.longitude
            latitude = location.coordinate.latitude
            
            Countly.sharedInstance().recordLocation(location.coordinate)
            User.shared.coordinateString = "longitude: \(self.longitude), latitude: \(self.latitude)"
            
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                if let placemark = placemarks?.last,
                    var administrativeArea = placemark.administrativeArea,
                    let country = placemark.country {
                    
                    let city = placemark.locality
                    let subCity = placemark.subLocality
                    
                    if city != nil || subCity != nil {
                        self.cityName = city ?? subCity!
                    } else {
                        self.cityName = "未知"
                    }
                    
                    if country == "中国" || country == "中國" {   // 中国地区
                        // 国内部分地区名称转换
                        if administrativeArea == "新疆维吾尔自治区" {
                            administrativeArea = "新疆"
                        }else if administrativeArea == "宁夏回族自治区" {
                            administrativeArea = "宁夏"
                        }else if administrativeArea == "内蒙古自治区" {
                            administrativeArea = "内蒙古"
                        }else if administrativeArea == "广西壮族自治区" {
                            administrativeArea = "广西省"
                        }else if administrativeArea == "香港特別行政區" {
                            administrativeArea = "香港"
                        }else if administrativeArea == "澳門特別行政區" {
                            administrativeArea = "澳门"
                        }else if administrativeArea == "西藏自治区" {
                            administrativeArea = "西藏"
                        }else if administrativeArea == "台灣省" {
                            administrativeArea = "台湾省"
                        }
                    } else {    // 海外地区，省份标为海外，城市取国家名
                        self.cityName = administrativeArea
                        administrativeArea = "海外"
                    }
                    
                    //                    if let index = self.provinceNames.index(of: administrativeArea) {
                    //                        let area = self.allArea.object(at: index) as! NSDictionary
                    //                        let citys = area["citys"] as! NSArray
                    //                        for city in citys {
                    //                            let cityDic = city as! Dictionary<String, AnyObject>
                    //                            let name = cityDic["titile"] as! String
                    //                            if name == self.cityName {
                    //                                self.cityID = cityDic["city_id"] as! Int
                    //                                break
                    //                            }
                    //                        }
                    //                    }
                    
                    self.procinceName = administrativeArea
                    
                    
                    for (id, name) in self.provinces {
                        if name == self.procinceName {
                            self.provinceId = id
                            break
                        }
                    }
                    
                    // Not uesd yet
                    UserDefaults.standard.setValue(self.cityName, forKey: "cityName")
                    UserDefaults.standard.setValue(self.cityID, forKey: "cityID")
                    UserDefaults.standard.setValue(self.procinceName, forKey: "procinceName")
                    UserDefaults.standard.setValue(self.provinceId, forKey: "procinceId")
                    
                    Countly.user().custom = ["province": self.procinceName, "city": self.cityName] as CountlyUserDetailsNullableDictionary
                    Countly.user().save()
                    
                    var tags = Set<NSObject>()
                    tags.insert("\(shangHuAppVersion)" as NSObject)
                    tags.insert("\(self.procinceName)" as NSObject)
                    tags.insert("\(self.cityName)" as NSObject)
                    JPUSHService.setTags(tags, callbackSelector: #selector(self.tagsAliasCallBack(resCode:tags:alias:)), object: self)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .notDetermined:
            printX("can not use location yet")
        default:
            printX("can use location now")
            manager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        printX("error: \(error)")
    }
    
    // MARK: - Helper
    
    func tagsAliasCallBack(resCode: CInt, tags: NSSet, alias: NSString) {
        //        let tips = "=== 注册地点响应结果：\(resCode)"
        //        print(tips)
    }
}
