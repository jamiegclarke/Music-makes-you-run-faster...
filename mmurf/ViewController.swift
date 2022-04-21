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
import SwiftyJSON
import Charts

var mapArr = [Location]()
var locname = [String]()
var connection = 0

var energy = [Double]()
var tempo = [Double]()
var paces = [Double]()
var rate = [Double]()
var genres = [String]()
var genreIndex = [String : Double]()

var topArtistImages = [String]()

var artistNameArr = [String]()
var songNameArr = [String]()
var songIdArr = [String]()
var artistIdArr = [String]()
var artistImageArr = [String]()

var flag = 1
var y = [Int]()
var x = [Int]()


class ViewController: UIViewController {
    
    @IBOutlet weak var greet1: UILabel!
    @IBOutlet weak var greet2: UILabel!
    @IBOutlet weak var greet3: UILabel!
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    
    @IBOutlet weak var map1: MKMapView!
    @IBOutlet weak var map2: MKMapView!
    @IBOutlet weak var map3: MKMapView!
    
    @IBOutlet weak var graph1: LineChartView!

    @IBOutlet weak var loadingscreen: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
        if self.traitCollection.userInterfaceStyle == .dark {
            greet1.text = "Good Evening"
            greet2.text = "Good Evening"
            greet3.text = "Good Evening"
        }
        else {
            let today = Date()
            
            let hours   = (Calendar.current.component(.hour, from: today))
            
            if hours > 12 {
                greet1.text = "Good Afternoon"
                greet2.text = "Good Afternoon"
                greet3.text = "Good Afternoon"
            }
            
        }
        
        if launchflag == false {
            
            getTopArtistImg()
            
            launchflag = true

            
        }
        else {
            
            setTopArtist()
            setMaps()
            graphLoaded(x: tempo, y: paces)
            loadingscreen.isHidden = true
            
        }
    }
    
    
    func getTopArtistImg() {
        
        let url = "https://api.spotify.com/v1/me/top/artists?time_range=medium_term&limit=3"
        
        Alamofire.request(url,headers: [
                        "Authorization": "Bearer " + spotifyoauth,
                        "Content-Type": "application/json"
                    ]
        ).responseJSON { response in switch response.result {
        case .success(let value):
            
            let json = JSON(value)

            

            topArtistImages.append(json["items"][0]["images"][0]["url"].stringValue)
            topArtistImages.append(json["items"][1]["images"][0]["url"].stringValue)
            topArtistImages.append(json["items"][2]["images"][0]["url"].stringValue)
            
            self.setTopArtist()
            self.getRecentActivity()
            
                
        case .failure(let error):
            print(error)
        }
      }
    }
    
    
    func getRecentActivity(){
   
        let unixtime = Date().timeIntervalSince1970
        
        let params = ["before": unixtime, "page": 1, "per_page": 3]
        StravaClient.sharedInstance.request(Router.athleteActivities(params: params), result: { [weak self] (activities: [Activity]?) in
            guard let self = self else { return }
            //print(activities)

            guard let activities = activities else { return }
            self.activities = activities
            
            
            if activities.isEmpty {
                print("Please Get More Running Data")
                let dialogMessage = UIAlertController(title: "ERROR", message: "Please Get More Running Data", preferredStyle: .alert)
  
                 let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                     exit(69)
                  })
                 
                 dialogMessage.addAction(ok)
                
                self.present(dialogMessage, animated: true, completion: nil)
                
            }
            else {
            
                let time = activities[0].movingTime
            
            for i in 0..<activities.count{
                    
                let activity = activities[i]
                mapArr.append(activity.startLatLng!)
                locname.append(activity.name!)
            
            
            }
            
            self.setMaps()
            
                self.getSongId(time: Int(time!))
            
            }
            
        }, failure: { (error: NSError) in
        
            debugPrint(error)
        })
        
        
        
    }
    
    var average = 0
    func getSongId(time: Int){
        
        let url = "https://api.spotify.com/v1/me/player/recently-played?limit=50"
        
        Alamofire.request(url,headers: [
                        "Authorization": "Bearer " + spotifyoauth,
                        "Content-Type": "application/json"
                    ]
                ).responseJSON { response in switch response.result {
                case .success(let value):
                    
                    let json = JSON(value)
                    
                    if json["items"].count != 50 {
                        print("Please Get More Listening Data")
                        let dialogMessage = UIAlertController(title: "ERROR", message: "Please Get More Listening Data", preferredStyle: .alert)
          
                         let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                             exit(69)
                          })
                         
                         dialogMessage.addAction(ok)
                        
                        self.present(dialogMessage, animated: true, completion: nil)
                        
                    }
                    else{
                        
                        var lengths = [Int]()
                        for i in 0..<json["items"].count {
                            lengths.append(json["items"][i]["track"]["duration_ms"].intValue)
                        }
                        
                        var total = 0
                        for length in lengths {
                            total+=length
                        }
                        
                        self.average = ((total/(lengths.count)/1000)/60)
                        
                        for i in 0..<(time/60)/(self.average){
                            artistNameArr.append(json["items"][i]["track"]["artists"][0]["name"].stringValue)
                            songNameArr.append(json["items"][i]["track"]["name"].stringValue)
                            songIdArr.append(json["items"][i]["track"]["id"].stringValue)
                            artistIdArr.append(json["items"][i]["track"]["artists"][0]["id"].stringValue)
                            artistImageArr.append(json["items"][i]["track"]["album"]["images"][0]["url"].stringValue)
                        }
                        
                        print(artistNameArr)
                        
                        self.getActivityId()
                    
                    }
                case .failure(let error):
                    print(error)
                    
                    
                }
              }
        
        
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
    
    var timer: Timer? = nil
    func getActivityId() {
        
        let unixtime = Calendar.current.date(byAdding: .month, value: 0, to: Date())!.timeIntervalSince1970
        
        
        let params = ["before": unixtime, "page": 1, "per_page": 1]
        StravaClient.sharedInstance.request(Router.athleteActivities(params: params), result: { [weak self] (activities3: [Activity]?) in
            guard let self = self else { return }
            //print(activities)

            guard let activities3 = activities3 else { return }
            self.activities3 = activities3
            
            let actid = activities3[0].id!
            
            
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                self.loading(id: actid)
                
            })

            
            
        }, failure: { (error: NSError) in
        
            debugPrint(error)
        })
        
       
    }

    func getPaces(id: Int) {
        StravaClient.sharedInstance.request(Router.activityStreams(id: id, types: "velocitySmooth"), result: { [weak self] (activities2: [StravaSwift.Stream]?) in
            guard let self = self else { return }
            
            guard let activities2 = activities2 else { return }
            self.activities2 = activities2
            
            
            var velocitySmooth = [Double]()
            
            for i in activities2[0].data! {
                velocitySmooth.append(i as! Double)
                    
            }
                
            var temp = [Double]()
            for i in 0..<velocitySmooth.count {
                //find difference in paces
                if i == 0 {
                    temp.append(velocitySmooth[i])
                }
                else {
                    temp.append(round(velocitySmooth[i] - velocitySmooth[i-1]))
                }
                    
                    
                }
                
            
            for i in 0..<temp.count {
                //find average of four values
                if i%(self.average) == 0{
                    if i != 0 {
                        var value = 0.0
                        for j in 0..<(self.average) {
                             value += temp[i-j]
                        }
                        paces.append((value)/Double((self.average)))
                        if paces.count == artistIdArr.count {
                                break
                        }
                        else if i == temp.count-1 {
                            while paces.count != artistIdArr.count {
                                paces.append(0.0)
                            }
                        }
                    }
                    
            }
                
        }
            
            
        }, failure: { (error: NSError) in

            debugPrint(error)
        })
        
        
    }
    
    func getHeartrate(id: Int) {
        StravaClient.sharedInstance.request(Router.activityStreams(id: id, types: "heartrate"), result: { [weak self] (activities2: [StravaSwift.Stream]?) in
            guard let self = self else { return }
            
            guard let activities2 = activities2 else { return }
            self.activities2 = activities2
            
            
            var heartrate = [Double]()
            
            for j in activities2[1].data! {
                heartrate.append(j as! Double)
            }
            
            
            for i in 0..<heartrate.count {
                if i%(self.average) == 0{
                    if i != 0 {
                        var value = 0.0
                        for j in 0..<(self.average) {
                             value += heartrate[i-j]
                        }
                        rate.append((value)/Double((self.average)))
                        if rate.count == artistIdArr.count {
                            break
                        }
                        else if i == heartrate.count-1 {
                            while rate.count != artistIdArr.count {
                                rate.append(0.0)
                            }
                        }
                        
    
                    }
                    
                }
                
            }
                    
                    
        }, failure: { (error: NSError) in

            debugPrint(error)
        })
        
        
    }
    
    fileprivate var activities3: [Activity] = []
    fileprivate var activities2: [StravaSwift.Stream] = []
    
    
    
    func getTempo() {
                
            for i in songIdArr {
                    let url = "https://api.spotify.com/v1/audio-features/" + i
                    Alamofire.request(url,headers: [
                                    "Authorization": "Bearer " + spotifyoauth,
                                    "Content-Type": "application/json"
                                ]
                            ).responseJSON { response in switch response.result {
                            case .success(let value):
                                
                                let json = JSON(value)
                                tempo.append(json["tempo"].doubleValue)
                                
                                
                            case .failure(let error):
                                print(error)
                                
                                
                            }
                    }
            }
    }
    
    func getEnergy() {
                
            for i in songIdArr {
                    let url = "https://api.spotify.com/v1/audio-features/" + i
                    Alamofire.request(url,headers: [
                                    "Authorization": "Bearer " + spotifyoauth,
                                    "Content-Type": "application/json"
                                ]
                            ).responseJSON { response in switch response.result {
                            case .success(let value):
                                
                                let json = JSON(value)
                                
                                energy.append(json["energy"].doubleValue)
                                
                            case .failure(let error):
                                print(error)
                                
                                
                            }
                    }
            }
        
    }
    
    func getGenre() {
        
            
        
            for i in 0..<artistIdArr.count {
                
                let url = "https://api.spotify.com/v1/artists/" + String(artistIdArr[i])
                
                Alamofire.request(url,headers: [
                                "Authorization": "Bearer " + spotifyoauth,
                                "Content-Type": "application/json"
                            ]
                        ).responseJSON { response in switch response.result {
                        case .success(let value):
                            
                            let json = JSON(value)
                            

                            for j in 0..<json["genres"].count {
                                
                                genres.append(json["genres"][j].stringValue)
                                
                                
                                if genreIndex[json["genres"][j].stringValue] != nil {
                                    
                                    if genreIndex[json["genres"][j].stringValue]! < paces[i] {
                                        genreIndex[json["genres"][j].stringValue] = paces[i]
                                    }
                                    
                                }
                                else {
                                    genreIndex[json["genres"][j].stringValue] = paces[i]
                                }
                                
                            }
                            
                            
                            
                        case .failure(let error):
                            print(error)
                            
                            
                        }
                    }
        }
            
        
    }
    
    var count = 0
    func loading(id: Int) {
        
        if count == 2 {
                print("Loading Complete")
                timer!.invalidate()
                print(artistNameArr)
                print(artistImageArr)
                print(tempo)
                print(energy)
                print(paces)
                print(rate)
                
        }
        else if paces.count == artistIdArr.count && rate.count == artistIdArr.count && tempo.count == artistIdArr.count && energy.count == artistIdArr.count && genres.count > artistIdArr.count {
                count = count + 1
                print("Song Genre Loaded...")
                graphLoaded(x: tempo, y: paces)
                        
        }
        else if paces.count == artistIdArr.count && rate.count == artistIdArr.count && tempo.count == artistIdArr.count && energy.count == artistIdArr.count {
                print("Song Energy Loaded...")
                getGenre()
        }
        else if paces.count == artistIdArr.count && rate.count == artistIdArr.count && tempo.count == artistIdArr.count {
                print("Song Tempo Loaded...")
                self.getEnergy()
        }
        else if paces.count == artistIdArr.count && rate.count == artistIdArr.count{
                print("Heartrate Loaded...")
                self.getTempo()
        }
        else if paces.count == artistIdArr.count {
                print("Paces Loaded...")
                self.getHeartrate(id: id)
        }
        else {
                if count == 0 {
                    count = count + 1
                    self.getPaces(id: id)
                }
        }
        
        

    }
            
    func graphLoaded(x: [Double], y: [Double]) {

        let yVals1 = (0..<x.count).map { (i) -> ChartDataEntry in
                return ChartDataEntry(x: x[i], y: y[i])
        }
            
        let set1 = ScatterChartDataSet(entries: yVals1)

        let data: ScatterChartData = [set1]


        graph1.data = data
        
        graph1.legend.enabled = false
        
        loadingscreen.isHidden = true
        graph1.animate(yAxisDuration: 0.5)
        graph1.leftAxis.labelTextColor = .white
        graph1.rightAxis.labelTextColor = .white
        graph1.xAxis.labelTextColor = .white
        data.setDrawValues(false)
                    
    }
    
    func setTopArtist(){
        self.image1.loadFrom(URLAddress: topArtistImages[0])
        self.image2.loadFrom(URLAddress: topArtistImages[1])
        self.image3.loadFrom(URLAddress: topArtistImages[2])
    }
    
    func setMaps() {
        
        if mapArr.count == 1 {
            let location1 = CLLocation(latitude: mapArr[0].lat!, longitude: mapArr[0].lng!)
            self.map1.centerToLocation(location1)
            let annotation1 = MKPointAnnotation()
            annotation1.coordinate = CLLocationCoordinate2D(latitude: mapArr[0].lat!, longitude: mapArr[0].lng!)
            self.map1.addAnnotation(annotation1)
            annotation1.title = locname[0]
        }
        if mapArr.count == 2 {
            let location1 = CLLocation(latitude: mapArr[0].lat!, longitude: mapArr[0].lng!)
            self.map1.centerToLocation(location1)
            let annotation1 = MKPointAnnotation()
            annotation1.coordinate = CLLocationCoordinate2D(latitude: mapArr[0].lat!, longitude: mapArr[0].lng!)
            self.map1.addAnnotation(annotation1)
            annotation1.title = locname[0]
            let location2 = CLLocation(latitude: mapArr[1].lat!, longitude: mapArr[1].lng!)
            self.map2.centerToLocation(location2)
            let annotation2 = MKPointAnnotation()
            annotation2.coordinate = CLLocationCoordinate2D(latitude: mapArr[1].lat!, longitude: mapArr[1].lng!)
            self.map2.addAnnotation(annotation2)
            annotation2.title = locname[1]
        }
        if mapArr.count == 3 {
            let location1 = CLLocation(latitude: mapArr[0].lat!, longitude: mapArr[0].lng!)
            self.map1.centerToLocation(location1)
            let annotation1 = MKPointAnnotation()
            annotation1.coordinate = CLLocationCoordinate2D(latitude: mapArr[0].lat!, longitude: mapArr[0].lng!)
            self.map1.addAnnotation(annotation1)
            annotation1.title = locname[0]
            let location2 = CLLocation(latitude: mapArr[1].lat!, longitude: mapArr[1].lng!)
            self.map2.centerToLocation(location2)
            let annotation2 = MKPointAnnotation()
            annotation2.coordinate = CLLocationCoordinate2D(latitude: mapArr[1].lat!, longitude: mapArr[1].lng!)
            self.map2.addAnnotation(annotation2)
            annotation2.title = locname[1]
            let location3 = CLLocation(latitude: mapArr[2].lat!, longitude: mapArr[2].lng!)
            self.map3.centerToLocation(location3)
            let annotation3 = MKPointAnnotation()
            annotation3.coordinate = CLLocationCoordinate2D(latitude: mapArr[2].lat!, longitude: mapArr[2].lng!)
            self.map3.addAnnotation(annotation3)
            annotation3.title = locname[2]
        }
        
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
