//
//  pace.swift
//  mmurf
//
//  Created by jamie goodrick-clarke on 30/03/2022.
//

import Foundation
import Alamofire
import StravaSwift

var paceimgart = ""
var pacenameart = ""

class pace: UIViewController {
    
    @IBOutlet weak var songimg: UIImageView!
    @IBOutlet weak var pace: UILabel!
    @IBOutlet weak var name: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var count = 0.0
        for i in 0..<artistIdArr.count{
            
            if paces[i] > count {
                count = paces[i]
            }
            
        }

        let index = Int(paces.firstIndex(of: count)!)
        songimg.loadFrom(URLAddress: String(artistImageArr[index]))
        pace.text = (round(count).description) + (" MPH")
        name.text = String(songNameArr[index])
        
        paceimgart = artistImageArr[index]
        pacenameart = songNameArr[index]
        
        }
        
    

                        
}
