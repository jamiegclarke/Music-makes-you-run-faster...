//
//  settings.swift
//  mmurf
//
//  Created by jamie goodrick-clarke on 24/02/2022.
//


//spotifyoauth and stravaoauth contains the access token. Made public so all classes can access information they need
var spotifyoauth = ""
var stravoauth = ""

import UIKit
import StravaSwift

// used to check if it is the first time launching to enable caching
var launchflag = false

class settings: UIViewController, SPTSessionManagerDelegate {
    
    //outlets for spotify and strava login images
    @IBOutlet weak var stravimage: UIImageView!
    @IBOutlet weak var spotimage: UIImageView!
    
    
    // Runs when view loads, checks each second if strava and spotify are authenticated. If one is authenticated their button disapears. If both are authentication screen segues to view controller
    var Login = 0
    var timer: Timer? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spotlogin.addTarget(self, action: #selector(didTapConnect(_:)), for: .touchUpInside)

        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            if spotifyoauth != "" && stravoauth != "" {
                    self.timer?.invalidate()
                    self.performSegue(withIdentifier: "start", sender: nil)
                        
                    }
            if spotifyoauth != "" {
                self.spotlogin.fadeOut()
                self.spotimage.fadeOut()

            }
            if stravoauth != "" {
                self.stralogin.fadeOut()
                self.stravimage.fadeOut()
                
            }
            
        })
    }
    
    
    //checks if application has lanuched before and sets launch flag on that basis
    func isAppAlreadyLaunchedOnce()->Bool{
            let defaults = UserDefaults.standard
            
            if defaults.bool(forKey: "isAppAlreadyLaunchedOnce"){
                launchflag = true
                return true
            }else{
                defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
                launchflag = false
                return false
            }
        }
    
    // set client id and redirectURL
    let SpotifyClientID = "7abf26d14c1c43499e2de1000028e6e0"
    let SpotifyRedirectURL = URL(string: "mmurf://returnAfterLogin")!
    
    
    //login button for spotify
    @IBOutlet weak var spotlogin: UIButton!
    
    //configures SPT authorisation protocols
    lazy var configuration: SPTConfiguration = {
           let configuration = SPTConfiguration(clientID: SpotifyClientID,
                                                redirectURL: SpotifyRedirectURL)
           configuration.playURI = "spotify:track:20I6sIOMTCkB6w7ryavxtO"

           return configuration
       }()
    
    
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


    // starts connection procedure and outlines scope
    @objc func didTapConnect(_ button: UIButton) {
        
        print("connecting...")

        let scopes: SPTScope = [.userReadEmail, .userReadPrivate,
        .userReadPlaybackState, .userModifyPlaybackState,
        .userReadCurrentlyPlaying, .streaming, .appRemoteControl,
        .playlistReadCollaborative, .playlistModifyPublic, .playlistReadPrivate, .playlistModifyPrivate,
        .userLibraryModify, .userLibraryRead,
        .userTopRead, .userReadPlaybackState, .userReadCurrentlyPlaying,
                                .userFollowRead, .userFollowModify, .userReadRecentlyPlayed ]
        
        self.sessionManager.initiateSession(with: scopes, options: .default)
        
    }

    //STP Session Manager stems, used to configure connection outcomes

    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("failed")
        
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("reconnected")
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("...")
        print("success")
        
        spotifyoauth = session.accessToken

    }
    

    
    
    
// Strava Authentication
    
    
    //logins in user to strava to authenticate
    var code: String?
    private var token: OAuthToken?

    @IBOutlet weak var stralogin: UIButton!
    
    @IBAction func login(_ sender: AnyObject) {
        print("connecting...")
        StravaClient.sharedInstance.authorize() { [weak self] (result: Result<OAuthToken, Error>) in
            guard let self = self else { return }
            print("authenticating...")
            
            self.didAuthenticate(result: result)
        }
    }

    //run when strava has authenticated with the application
    private func didAuthenticate(result: Result<OAuthToken, Error>) {
        switch result {
            case .success(let token):
                print("connection success!")

                self.token = token
                stravoauth = token.accessToken!
                
            case .failure(let error):
                debugPrint(error)
        }
    }
    
   

}






// Fading in and out button animation

extension UIView {

    func fadeIn(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 1 },
                       completion: { (value: Bool) in
                          if let complete = onCompletion { complete() }
                       }
        )
    }

    func fadeOut(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 0 },
                       completion: { (value: Bool) in
                           self.isHidden = true
                           if let complete = onCompletion { complete() }
                       }
        )
    }

}
    

