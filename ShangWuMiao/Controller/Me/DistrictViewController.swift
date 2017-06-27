//
//  DistrictViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/27.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit


class AreaCell: UITableViewCell {
    @IBOutlet weak var areaLabel: UILabel!
}

class DistrictViewController: UIViewController {

    @IBOutlet weak var provinceTableView: UITableView! {
        didSet {
            provinceTableView.dataSource = self
            provinceTableView.delegate = self
        }
    }
    @IBOutlet weak var cityTableView: UITableView! {
        didSet {
            cityTableView.dataSource = self
            cityTableView.delegate = self
        }
    }

    @IBOutlet weak var districtTableView: UITableView! {
        didSet {
            districtTableView.dataSource = self
            districtTableView.delegate = self
        }
    }
    
    
    fileprivate var selectedProvince: (id: Int, name: String)!
    fileprivate var selectedCity: (id: Int, name: String)!
    fileprivate var selectedDistrict: (id: Int, name: String)!
    
    // [(id: 440000, name: 广东省)]
    fileprivate var provinces: Array = [(id: Int, name: String)]()
    
    // "广东省": [(id: 440100, name: "广州市"), (id: 440200, name: "韶关市"), ....]
    fileprivate var cities: Dictionary = Dictionary<String, [(id: Int, name: String)]>()
    
    // "深圳市": [(id: 910976, name: "光明新区"), (id: 440301, name: "坪山区"), ....]
    fileprivate var districtes: Dictionary = Dictionary<String, [(id: Int, name: String)]>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializerData()
        
        
//        print("provinces: \(provinces)\n\n\n\n")
//        print("cities: \(cities)\n\n\n")
//        print("districtes: \(districtes)")

        
        for data in self.cities {
            print("data: \(data)\n")
        }
    }
    
    
    // MARK: - Helper
    private func initializerData() {
        if let file = Bundle.main.path(forResource: "Area", ofType: "plist"),
            let erea = NSMutableArray(contentsOfFile: file) {
            let allArea = NSMutableOrderedSet(array: erea as [AnyObject])
            
            for area in allArea {
                let areaDic = area as! Dictionary<String, AnyObject>
                let provinceName = areaDic["title"] as! String
                let provinceId = areaDic["province_id"] as! Int
                let provinceData = (id: provinceId, name: provinceName)
                provinces.append(provinceData)
                
                var innerCities = [(id: Int, name: String)]()
                let citiesArray = areaDic["citys"] as! [Dictionary<String, AnyObject>]
                
                for city in citiesArray {
                    let cityId = city["city_id"] as! Int
                    let cityName = city["titile"] as! String
                    let cityData = (cityId, cityName)
                    innerCities.append(cityData)
                    
                    var innerDistrictes = [(id: Int, name: String)]()
                    let districtes = city["areas"] as! [Dictionary<String, AnyObject>]
                    
                    for district in districtes {
                        let districtId = district["area_id"] as! Int
                        let districtName = district["area_name"] as! String
                        let districtData = (districtId, districtName)
                        innerDistrictes.append(districtData)
                    }
                    
                    self.districtes[cityName] = innerDistrictes
                }
                
                self.cities[provinceName] = innerCities
            }
        }
    }
    
}


extension DistrictViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if tableView == provinceTableView {
            count = self.provinces.count
        } else if tableView == cityTableView {
            if let provinceName = self.selectedProvince?.name {
                count = self.cities[provinceName]!.count
            }
        } else {
            if let cityName = self.selectedCity?.name {
                count = self.districtes[cityName]!.count
            }
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell Identifier", for: indexPath)
        if tableView == provinceTableView {
            if let cell = cell as? AreaCell {
                cell.areaLabel.text = provinces[indexPath.row].name
            }
        } else if tableView == cityTableView {
        } else {   // district table view
        }
        return cell
    }
}


extension DistrictViewController: UITableViewDelegate {
}
