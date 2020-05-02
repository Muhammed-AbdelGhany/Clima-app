//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SVProgressHUD


class WeatherViewController: UIViewController , CLLocationManagerDelegate , ChangeCityDelegate {

    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        //TODO:Set up the location manager here.
    
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func gETWeatherData(url : String , parameters : [String : String]) {
        
        Alamofire.request(url , method: .get , parameters: parameters ).responseJSON {
            response in
            if response.result.isSuccess{
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            }
            else{
                print()
                print(" somthing went wrong with getting data \n the error is /t \(response.result.error)" )
            }
            
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData (json : JSON){
        if let temp = json["main"]["temp"].double{
            weatherDataModel.tempreture = Int (temp - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
            
        }
        else{
            print(" error at Json parsing ")
        }
        
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData (){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.tempreture)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last{
       
        if  location.horizontalAccuracy >  0 {
            locationManager.stopUpdatingLocation()
            
            let longitude = String (location.coordinate.longitude)
            let latitude = String (location.coordinate.latitude)
            let params : [String:String] = ["lat":latitude, "lon":longitude, "appid":APP_ID  ]
            gETWeatherData(url: WEATHER_URL, parameters: params)
        }
        }}
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Cant find city"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredCityName(city: String) {
        let params :[String : String] = ["q" : city , "appid" : APP_ID ]
        gETWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destenationVC = segue.destination as! ChangeCityViewController
            destenationVC.delegate=self
            
        }}
    
    
    
}


