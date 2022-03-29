//
//  running.swift
//  mmurf
//
//  Created by jamie goodrick-clarke on 29/03/2022.
//

import Foundation
import Alamofire

class running: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var artistimg: UIImageView!
    @IBOutlet weak var amount: UILabel!
    
    
    
    override func viewDidLoad() {
        
        let url = "https://api.spotify.com/v1/me/player/recently-played?limit=50&after=" + String(starttime)
        
        Alamofire.request(url,headers: [
                        "Authorization": "Bearer " + spotifyoauth,
                        "Content-Type": "application/json"
                    ]
                ).responseString { response in
           
                
            
                let topArr = ("\(response)".split(separator: ","))
                
                var nameArr = [String]()
                
                for i in topArr{
                    if (i.contains("name")){
                        
                        let artist = i.split(separator: ":")
                        
                        for j in artist {
                            if !j.contains("name") {
                                nameArr.append(String(j))
                            }
                        }
                        
                    
                        
                    }
                    
                }
            
            let figures = self.getMostCommonWord(array: nameArr)
            
            self.name.text = String((figures.mostCommonWord.dropFirst(2)).dropLast(1))
            self.amount.text = String(figures.amo) + " times"
            
            var imgArr = [String]()
            
            for i in topArr{
                if (i.contains("https")) && (i.contains("image")){
                    
                    imgArr.append(String(i))
                    
                
                    
                }
                
            }
            
            let imgurl = self.getMostCommonWord(array: imgArr)
            
            self.artistimg.loadFrom(URLAddress: String((((imgurl.mostCommonWord.replacingOccurrences(of: " ", with: "")).dropFirst(8))).dropLast(1)))
            
            
     
        }
        
        
    
    
    }
    
    func getMostCommonWord(array: [String]) -> (mostCommonWord: String, amo: Int) {
        
        var dict = [String: Int]()
        var amo = 0
        
        for word in array {
            if let count = dict[word] {
                dict[word] = count + 1
            } else {
                dict[word] = 1
            }
        }
        
        var mostCommonWord = ""
        for key in dict.keys {
            if mostCommonWord == "" {
                mostCommonWord = key
            }
            if let nextCount = dict[key], let prevCount = dict[mostCommonWord] {
                if nextCount > prevCount {
                    mostCommonWord = key
                    amo = nextCount
                    
                }
            }
        }
        
        return (mostCommonWord, amo)
    }
                        
}
