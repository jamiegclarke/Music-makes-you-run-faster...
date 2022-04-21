//
//  AppDelegate.swift
//  mmurf
//
//  Created by jamie goodrick-clarke on 15/02/2022.
//

import UIKit

import StravaSwift

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var strava = StravaClient.sharedInstance
    
    let config = StravaConfig(
      clientId: 78330,
      clientSecret: "341fb6bce2f69cb9fc41f6515d83b238cfe223b7",
      redirectUri: "mmurf://mmurf.com".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
      scopes: [.readAll, .read, .profileWrite, .profileReadAll, .activityWrite, .activityRead, .activityReadAll]
      )

    override init() {
        self.strava = StravaClient.sharedInstance.initWithConfig(config)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      return strava.handleAuthorizationRedirect(url)
        
    }

    
}


