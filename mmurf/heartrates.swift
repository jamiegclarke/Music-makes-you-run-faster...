//
//  heartrate.swift
//  mmurf
//
//  Created by jamie goodrick-clarke on 05/04/2022.
//

import Foundation

var topamoheart = ""
var topimgheart = ""

class heartrates: UIViewController {
    
    @IBOutlet weak var songimg: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var bpm: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let topheart = rate.max()
        
        let index = Int(rate.firstIndex(of: topheart!)!)
        topamoheart = songNameArr[index]
        songTitle.text = songNameArr[index]
        bpm.text = String(round(topheart!)) + " BPM"
        songimg.loadFrom(URLAddress: artistImageArr[index])
        topimgheart = artistImageArr[index]
        
        
        }
        
}
