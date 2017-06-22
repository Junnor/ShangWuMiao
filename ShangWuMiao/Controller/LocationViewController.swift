//
//  LocationViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/22.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    
    private var manager: CLLocationManager!
    
    private lazy var allArea: NSMutableOrderedSet = {
        guard let file = Bundle.main.path(forResource: "Area", ofType: "plist"),
            let erea = NSMutableArray(contentsOfFile: file) else {
                return []
        }
        return NSMutableOrderedSet(array: erea as [AnyObject])
    }()
    
    
    private var provinceNames: [String]!
    private var provinceIds: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for area in allArea {
            let dic = area as! Dictionary<String, AnyObject>
            let name = dic["title"] as! String
            let id = dic["province_id"] as! Int
            
            provinceNames.append(name)
            provinceIds.append(id)
        }
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 50
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    private var cityName = ""
    private var cityID = 0
    private var procinceName = ""
    private var provinceId = 0
    private var longitude = CLLocationDegrees(110.1210)
    private var latitude = CLLocationDegrees(19.10)
    
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
                    
                    if country == "中国" || country == "中國" {
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
                    }
                    
                    self.procinceName = administrativeArea
                    
                    let city = placemark.locality
                    let subCity = placemark.subLocality
                    
                    if city != nil || subCity != nil {
                        self.cityName = city ?? subCity!
                    } else {
                        self.cityName = "未知"
                    }
                    
                    if let index = self.provinceNames.index(of: administrativeArea) {
                        let area = self.allArea.object(at: index) as! NSDictionary
                        let citys = area["citys"] as! NSArray
                        for city in citys {
                            let cityDic = city as! Dictionary<String, AnyObject>
                            let name = cityDic["titile"] as! String
                            if name == self.cityName {
                                self.cityID = cityDic["city_id"] as! Int
                                break
                            }
                        }
                    }
                    
                    // Not uesd yet
                    UserDefaults.standard.setValue(self.cityName, forKey: "cityName")
                    UserDefaults.standard.setValue(self.cityID, forKey: "cityID")
                    UserDefaults.standard.setValue(self.procinceName, forKey: "procinceName")

                    // got cityName, cityId, province
                    
                    var tags = Set<NSObject>()
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
            print("Can not use location yet")
        default:
            print("Can use location")
            manager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location fail with error: \(error)")
    }
    
    // MARK: - Helper
    
    func tagsAliasCallBack(resCode: CInt, tags: NSSet, alias: NSString) {
        let tips = "响应结果：\(resCode)"
        print(tips)
    }
    
    
}
