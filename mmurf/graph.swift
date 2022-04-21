//
//  graph.swift
//  mmurf
//
//  Created by jamie goodrick-clarke on 31/03/2022.
//

import Foundation
import Charts
import Alamofire


class graph: UIViewController {
    
    @IBOutlet weak var chtChart: LineChartView!
    @IBOutlet weak var desc: UILabel!
    
    var co = 0.0
    
    override func viewDidLoad() {
        
        setChart(x: tempo, y: paces)
        
        co = calccoefficient(X: tempo, Y: paces)
        
        if co > 0 {
            desc.text = "Your speed increased as the tempo of your songs increased. Listen to more high tempo songs."
            setRecomendations(correlation: 0, type: "tempo")
        }
        else if co < 0 {
            desc.text = "Your speed increased as the tempo of your songs decreased. Listen to less high tempo songs."
            setRecomendations(correlation: 1, type: "tempo")
        }
        
        
    }
    
    func setChart(x: [Double], y: [Double]) {
        
        let yVals1 = (0..<x.count).map { (i) -> ChartDataEntry in
                return ChartDataEntry(x: x[i], y: y[i])
        }
            
        let set1 = ScatterChartDataSet(entries: yVals1)

        let data: ScatterChartData = [set1]


        chtChart.data = data
        chtChart.animate(yAxisDuration: 0.5)
        chtChart.legend.enabled = false
        
        chtChart.leftAxis.labelTextColor = .white
        chtChart.rightAxis.labelTextColor = .white
        chtChart.xAxis.labelTextColor = .white
        data.setDrawValues(false)
      
    }
        
    
    @IBAction func button1(_ sender: Any) {
        setChart(x: tempo, y: paces)
        co = calccoefficient(X: tempo, Y: paces)
        
        if co > 0 {
            desc.text = "Your speed increased as the tempo of your songs increased. Listen to more high tempo songs."
            setRecomendations(correlation: 0, type: "tempo")
            
        }
        else if co < 0 {
            desc.text = "Your speed increased as the tempo of your songs decreased. Listen to less high tempo songs."
            setRecomendations(correlation: 1, type: "tempo")
            
        }
    }
    
    @IBAction func button2(_ sender: Any) {
        setChart(x: tempo, y: rate)
        co = calccoefficient(X: tempo, Y: rate)
        
        if co > 0 {
            desc.text = "Your heartrate increased as the tempo of your songs increased. Listen to more high tempo songs."
            setRecomendations(correlation: 0, type: "tempo")
            
        }
        else if co < 0 {
            desc.text = "Your heartrate increased as the tempo of your songs decreased. Listen to less high tempo songs."
            setRecomendations(correlation: 1, type: "tempo")
            
        }
    }
    @IBAction func button3(_ sender: Any) {
        setChart(x: energy, y: paces)
        co = calccoefficient(X: energy, Y: paces)
        
        if co > 0 {
            desc.text = "Your speed increased as the energy of your songs increased. Listen to more high energy songs."
            setRecomendations(correlation: 0, type: "energy")
        }
        else if co < 0 {
            desc.text = "Your speed increased as the energy of your songs decreased. Listen to less high energy songs."
            setRecomendations(correlation: 1, type: "energy")
            
        }
    }
    
    func calccoefficient(X: [Double], Y: [Double]) -> Double{
        
        var sumX = 0.0
        var sumY = 0.0
        var sumXY = 0.0
        var squaresumX = 0.0
        var squaresumY = 0.0
        let n = Double(X.count)
        
        for i in 0..<X.count {
            
            sumX += X[i]
            sumY += Y[i]
            sumXY += X[i] * Y[i]
            squaresumX += X[i] * X[i]
            squaresumY += Y[i] * Y[i]
            
        }
        var sum1 = 0.0
        sum1 = n * sumXY - sumX * sumY
        var sum2 = 0.0
        sum2 = (((n * squaresumX) - (sumX * sumX)) * (n * squaresumY - sumY * sumY)).squareRoot()
        let corr = sum1 / sum2
        return(corr)
        
    }
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    
    
    func setRecomendations(correlation: Int, type: String) {
        
        var rec = [Int]()
        
        image1.loadFrom(URLAddress: "https://pitshanger-ltd.co.uk/images/colours/570-Pink%20MR.JPG")
        image2.loadFrom(URLAddress: "https://pitshanger-ltd.co.uk/images/colours/570-Pink%20MR.JPG")
        image3.loadFrom(URLAddress: "https://pitshanger-ltd.co.uk/images/colours/570-Pink%20MR.JPG")
        image4.loadFrom(URLAddress: "https://pitshanger-ltd.co.uk/images/colours/570-Pink%20MR.JPG")
        
        
        if type == "tempo" {
            if correlation == 0 {

                for i in tempo {
                    if i > 120 {
                        rec.append(Int(tempo.firstIndex(of: i)!))
                    }
                }
            }
            else {

                for i in tempo {
                    if i < 120 {
                        rec.append(Int(tempo.firstIndex(of: i)!))
                    }
                }
            }
            
        }
        else if type == "energy" {
            if correlation == 0 {
  
                for i in energy {
                    if i > 0.3 {
                        rec.append(Int(energy.firstIndex(of: i)!))
                    }
                }
            }
            else {
                
                for i in energy {
                    if i > 0.3 {
                        rec.append(Int(energy.firstIndex(of: i)!))
                    }
                }
            }
        }
        
        if rec.count > 0 {
        image1.loadFrom(URLAddress: artistImageArr[rec[0]])
        }
        if rec.count > 1 {
        image2.loadFrom(URLAddress: artistImageArr[rec[1]])
        }
        if rec.count > 2 {
        image3.loadFrom(URLAddress: artistImageArr[rec[2]])
        }
        if rec.count > 3 {
        image4.loadFrom(URLAddress: artistImageArr[rec[3]])
        }
        
        
        
    }
                        


}
