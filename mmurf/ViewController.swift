//
//  ViewController.swift
//  mmurf
//
//  Created by jamie goodrick-clarke on 23/02/2022.
//

import UIKit

import Alamofire
import StravaSwift
import MapKit

var mapArr = [Location]()
var locname = [String]()
var connection = 0
var starttime = 0

class ViewController: UIViewController {
    
    
    let parameters = ["Accept": "application/json", "Content-Type": "application/json", "Authorization": spotifyoauth]
    let url = "https://api.spotify.com/v1/me/top/artists?time_range=medium_term&limit=3"
    
    
    let url2 = "https://www.strava.com/api/v3/athlete"
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    
    @IBOutlet weak var map1: MKMapView!
    @IBOutlet weak var map2: MKMapView!
    @IBOutlet weak var map3: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
        print("Spotify oAUTH TOKEN = " + spotifyoauth)
        print("Strava oAUTH TOKEN = " + stravoauth)
        
        Alamofire.request(self.url,headers: [
                        "Authorization": "Bearer " + spotifyoauth,
                        "Content-Type": "application/json"
                    ]
                ).responseString { response in
           
                
            let topArr = ("\(response)".split(separator: "\""))
            
            var imageArr = [String]()
            
            for i in topArr{
                if (i.contains("image") && i.contains("http")){
                    
                    
                    imageArr.append(String(i))
                    
                }
            }
            
            if !imageArr.isEmpty {
                
                self.image1.loadFrom(URLAddress: imageArr[0])
                self.image2.loadFrom(URLAddress: imageArr[3])
                self.image3.loadFrom(URLAddress: imageArr[6])
                
                
            }
        }
        
        update()
    
    }
    
    func update() {
        let month = 0
        let date = Calendar.current.date(byAdding: .month, value: month, to: Date())!
        print(date)
        let unixtime = date.timeIntervalSince1970
        
        
        let params = ["before": unixtime, "page": 1, "per_page": 3]
        StravaClient.sharedInstance.request(Router.athleteActivities(params: params), result: { [weak self] (activities: [Activity]?) in
            guard let self = self else { return }
            //print(activities)

            guard let activities = activities else { return }
            self.activities = activities
            
            
            
            if !activities.isEmpty {
            
                for i in 0...2{
                    
                    let activity = activities[i]
                    mapArr.append(activity.startLatLng!)
                    locname.append(activity.name!)
                
                }
                
                //for maps
                
                let location1 = CLLocation(latitude: mapArr[0].lat!, longitude: mapArr[0].lng!)
                self.map1.centerToLocation(location1)
                let location2 = CLLocation(latitude: mapArr[1].lat!, longitude: mapArr[1].lng!)
                self.map2.centerToLocation(location2)
                let location3 = CLLocation(latitude: mapArr[2].lat!, longitude: mapArr[2].lng!)
                self.map3.centerToLocation(location3)
                
                let annotation1 = MKPointAnnotation()
                annotation1.coordinate = CLLocationCoordinate2D(latitude: mapArr[0].lat!, longitude: mapArr[0].lng!)
                self.map1.addAnnotation(annotation1)
                annotation1.title = locname[0]
                
                let annotation2 = MKPointAnnotation()
                annotation2.coordinate = CLLocationCoordinate2D(latitude: mapArr[1].lat!, longitude: mapArr[1].lng!)
                self.map2.addAnnotation(annotation2)
                annotation2.title = locname[1]
                
                let annotation3 = MKPointAnnotation()
                annotation3.coordinate = CLLocationCoordinate2D(latitude: mapArr[2].lat!, longitude: mapArr[2].lng!)
                self.map3.addAnnotation(annotation3)
                annotation3.title = locname[2]
                
                
                //for story
                
                let recentactivity = activities[0]
                let starttimedate = recentactivity.startDate
                starttime = Int(starttimedate!.timeIntervalSince1970)
                print(starttime)

            }
        }, failure: { (error: NSError) in
        
            debugPrint(error)
        })
    }
    
    fileprivate var activities: [Activity] = []
    
    @IBAction func button1(_ sender: Any) {
        connection = 0
    }
    
    @IBAction func button2(_ sender: Any) {
        connection = 1
    }
    @IBAction func button3(_ sender: Any) {
        connection = 2
    }
    
    
    
    
    
    
    
}




extension UIImageView {
    func loadFrom(URLAddress: String) {
        guard let url = URL(string: URLAddress) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                        self?.image = loadedImage
                }
            }
        }
    }
}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 5000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
