//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

// Networking Notes
/*
 What is networking?
    The communication between different computer systems
    Example: Say type in www.google.com
        - Your browser makes a request to google serer and google gives back html and css files
        1) Makes HTTP request to server
        2) website server grants request
        3) browser interprets the code
 
 Git Request
    GET - getting cookies, fetching data
    POST - pass data to server and add data
    DELETE - make a request to server in order to delete some data in server
 
 

*/
 
import UIKit
import CoreLocation
import Alamofire // A library of code that will help making requests
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, changeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self // Helps us get the locations (Built by APPLE) 
        // Delegate Definition: We will be the ones who use the location (self)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() // Starts looking for the GPS coordination of the Iphone
        
        
    }
    
    
    
    //MARK: - Networking
    
/* NOTES:
     
     
 
*/
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String : String]){
        
        // .get : get data from the url
        // parameters - what the server needs to get the data
        // This request happens in the background (ASYNCRHONOUS) 
        // once ready, .response will get the data and see if it was successful...
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            // closure (in) function inside a function.. 
            // solution.. whenever you are inside closure, always put self infront of functions
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                //format and process to display on screen
                
                // JSON = JavaScript Object Notation
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
                
            }
            else{ // what should happen if there is an error
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON) {
        
        // find entire json, go find key main and all its value, then look for a key named temp and pull value
        if let tempResult = json["main"]["temp"].double {
     
        weatherDataModel.temperature = Int((tempResult - 273.15) * 1.8 + 32)
        
        weatherDataModel.city = json["name"].stringValue
        
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition:
            weatherDataModel.condition)
            
        updateUIWithWeatherData()
        
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(){
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    

    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if(location.horizontalAccuracy > 0){
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
        }
        
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        
        let params : [String:String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        
        let params : [String: String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
        
    }
    

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
            
        }
        
    }
    
    
    
}


