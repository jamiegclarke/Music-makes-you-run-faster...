//
//  settings.swift
//  mmurf
//
//  Created by jamie goodrick-clarke on 24/02/2022.
//

var spotifyoauth = ""
var stravoauth = ""

import UIKit
import StravaSwift

class settings: UIViewController, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate{
    
    let SpotifyClientID = "7abf26d14c1c43499e2de1000028e6e0"
    let SpotifyRedirectURL = URL(string: "mmurf://returnAfterLogin")!
    
    @IBOutlet weak var spotlogin: UIButton!
    
    
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

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self
        
        return appRemote
    }()
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      self.sessionManager.application(app, open: url, options: options)
      
      return true
    }

    private var lastPlayerState: SPTAppRemotePlayerState?

    // MARK: - Subviews

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spotlogin.addTarget(self, action: #selector(didTapConnect(_:)), for: .touchUpInside)
        
        updateViewBasedOnConnected()
    }

    func updateViewBasedOnConnected() {
        if (appRemote.isConnected) {
            spotlogin.tintColor = UIColor(red: 0.6784, green: 1, blue: 0.6784, alpha: 1.0)
        } else {
            print("Fail")
        }
    }

    // MARK: - Actions

    @objc func didTapPauseOrPlay(_ button: UIButton) {
        if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
            appRemote.playerAPI?.resume(nil)
        } else {
            appRemote.playerAPI?.pause(nil)
        }
    }

    @objc func didTapDisconnect(_ button: UIButton) {
        if (appRemote.isConnected) {
            appRemote.disconnect()
        }
    }

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


    // MARK: - SPTSessionManagerDelegate

    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("...")
        print("success")
        
        spotifyoauth = session.accessToken
        
        appRemote.connectionParameters.accessToken = session.accessToken
        self.appRemote.connect()
    }

    // MARK: - SPTAppRemoteDelegate

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        updateViewBasedOnConnected()
        
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print("Error subscribing to player state:" + error.localizedDescription)
            }
        })
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        updateViewBasedOnConnected()
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        updateViewBasedOnConnected()
        lastPlayerState = nil
    }

    // MARK: - SPTAppRemotePlayerAPIDelegate

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
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

    // MARK: - Private Helpers

    private func presentAlertController(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
            controller.addAction(action)
            self.present(controller, animated: true)
        }
    }
    
    

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

    private func didAuthenticate(result: Result<OAuthToken, Error>) {
        switch result {
            case .success(let token):
                print("connection success!")
                self.token = token
                stravoauth = token.accessToken!
                
             
            
            stralogin.tintColor = UIColor(red: 0.6784, green: 1, blue: 0.6784, alpha: 1.0)
            case .failure(let error):
                debugPrint(error)
        }
    }
    
   

}
    

