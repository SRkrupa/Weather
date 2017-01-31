//
//  ViewController.swift
//  WeatherApp
//
//  Created by Roopika 1/31/17.
//  Copyright © 2017 Roopika. All rights reserved.
//

import UIKit
let API_KEY = "a368338e304b89ec2073b53a407a1fac"

class ViewController: UIViewController, UISearchBarDelegate {
    
    
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var weatherLabel: UILabel!
    @IBOutlet var iconImageview: UIImageView!
    
    
    
    let defaults = UserDefaults.standard
    
    
    
    func getWeatherInformation(searchText: String, completion: @escaping ((_ result : [String: Any]?) ->()))
    {
        var urlPath = "\(searchText)&appid=\(API_KEY)&units=metric"
        urlPath =  urlPath.trimmingCharacters(in: .whitespaces)
        
        MyNetwork.instance.requestWithUri(urlPath, httpMethod: HTTPMethod.GET, httpBodyParameters: nil, completion: { status, response, error in
            if let exists = response as? [String: AnyObject]
            {
                completion(exists)
                
            }
            else
            {
                completion(nil)
            }
        })
        
    }
    
    func downloadWeatherIcondWithName(icon:String)
    {
        let urlPath = "http://openweathermap.org/img/w/\(icon).png"
        MyNetwork.instance.downloadImage(urlPath, completion: {(data) in
            
            DispatchQueue.main.async(execute: {
                
                if data != nil
                {
                    self.iconImageview.image = UIImage(data: data!)
                }
                
                
            })
            
        })
        
        
    }
    
    func downloadWeather(cityText: String?)
    {
        if let text = cityText
        {
            self.getWeatherInformation(searchText: text, completion: { (result) in
                
                DispatchQueue.main.async(execute: {
                    if result?["cod"] as? Int == 200
                    {
                        if let weather = result?["weather"] as? [[String: Any]], weather.count>0
                        {
                            let dict = weather[0]
                            self.weatherLabel.text = dict["description"] as? String
                            
                            self.downloadWeatherIcondWithName(icon: dict["icon"]as! String)
                        }
                        
                        if let tempDict = result?["main"] as? [String: Any]
                        {
                            let temp = tempDict["temp"] as? Double
                            self.tempLabel.text = "\(lround(temp!))ºC"
                            
                        }
                    }
                })
            })
        }
        
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if text != ""
        {
            let proposedText = (searchBar.text as? NSString)?.replacingCharacters(in: range, with: text)
            
            self.downloadWeather(cityText: proposedText)
            
            
            return true
        }
        
        return false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.downloadWeather(cityText: searchBar.text)
        
        defaults.set(searchBar.text, forKey: "someObject")
        
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (defaults.object(forKey: "someObject") != nil)
        {
            
            print(defaults.object(forKey: "someObject"));
//           
            
//            self.downloadWeather(cityText: "Newyork")
            self.downloadWeather(cityText: defaults.object(forKey: "someObject") as! String?)
        }
        else
        {
            self.downloadWeather(cityText: "Newyork")
        }
        
        
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


