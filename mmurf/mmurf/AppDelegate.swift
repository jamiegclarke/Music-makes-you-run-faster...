//
//  AppDelegate.swift
//  mmurf
//
//  Created by jamie goodrick-clarke on 15/02/2022.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    
    // MARK: Variables
    
    let SpotifyClientID = "7abf26d14c1c43499e2de1000028e6e0"
    let SpotifyRedirectURL = URL(string: "mmurf://returnAfterLogin")!

    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )
    
    lazy var sessionManager: SPTSessionManager = {
      if let tokenSwapURL = URL(string: "https://mmurf.herokuapp.com/api/token"),
         let tokenRefreshURL = URL(string: "https://mmurf.herokuapp.com/api/refresh_token") {
        self.configuration.tokenSwapURL = tokenSwapURL
        self.configuration.tokenRefreshURL = tokenRefreshURL
        self.configuration.playURI = ""
      }
        
      let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
      return manager
        
    }()
    
    lazy var appRemote: SPTAppRemote = {
            let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
            appRemote.delegate = self
            return appRemote
        }()
    
    
    // MARK: Methods

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.configuration.playURI = ""
        
        let requestedScopes: SPTScope = [.appRemoteControl]
        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      self.sessionManager.application(app, open: url, options: options)
      return true
    }
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
      print("success", session)
        self.appRemote.connectionParameters.accessToken = session.accessToken
        self.appRemote.connect()
    }
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
      print("fail", error)
    }
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
      print("renewed", session)
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
            print("connected")
            
            self.appRemote.playerAPI?.delegate = self
            self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
            })
        
    }
        
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
                print("disconnected")
    }
            
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
                print("failed")
    }

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
                print("player state changed")
                print("isPaused", playerState.isPaused)
                print("track.uri", playerState.track.uri)
                print("track.name", playerState.track.name)
                print("track.imageIdentifier", playerState.track.imageIdentifier)
                print("track.artist.name", playerState.track.artist.name)
                print("track.album.name", playerState.track.album.name)
                print("track.isSaved", playerState.track.isSaved)
                print("playbackSpeed", playerState.playbackSpeed)
                print("playbackOptions.isShuffling", playerState.playbackOptions.isShuffling)
                print("playbackOptions.repeatMode", playerState.playbackOptions.repeatMode.hashValue)
                print("playbackPosition", playerState.playbackPosition)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
            // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
            // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
            if self.appRemote.isConnected {
                self.appRemote.disconnect()
            }
        }

    func applicationDidBecomeActive(_ application: UIApplication) {
            // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
            if let _ = self.appRemote.connectionParameters.accessToken {
                self.appRemote.connect()
            }
        }
    

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    
    
    

    
    

}


