//
//  mainmap.swift
//  mmurf
//
//  Created by jamie goodrick-clarke on 22/03/2022.
//

import Foundation
import MapKit

class mainmap: UIViewController {
    
    @IBOutlet weak var mainmap: MKMapView!
    
    override func viewDidLoad() {
        
        let location = CLLocation(latitude: mapArr[connection].lat!, longitude: mapArr[connection].lng!)
        self.mainmap.centerToLocation(location)
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: mapArr[connection].lat!, longitude: mapArr[connection].lng!)
        self.mainmap.addAnnotation(annotation)
        annotation.title = locname[connection]
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
