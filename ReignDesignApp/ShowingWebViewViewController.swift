//
//  ShowingWebViewViewController.swift
//  ReignDesignApp
//
//  Created by Israel on 04/09/17.
//  Copyright © 2017 IsraelGutierrez. All rights reserved.
//

import UIKit

class ShowingWebViewViewController: UIViewController, UIWebViewDelegate {
    
    private var postCDData: PostCD! = nil
    private var mainWebView: UIWebView! = nil
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(newPost: PostCD) {
        
        postCDData = newPost
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    override func loadView() {
        
        self.view = UIView.init(frame: UIScreen.main.bounds)
        self.view.backgroundColor = UIColor.white
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.initInterface()
        
    }
    
    private func initInterface() {
        
        self.initMainWebView()
        
        UtilityManager.sharedInstance.showLoader()
        
        let urlFromString = URL.init(string: postCDData.url!)
        
        if urlFromString != nil {
            
            let urlRequest = URLRequest.init(url: urlFromString!)
            self.mainWebView.loadRequest(urlRequest)
            
        } else {
            
            UtilityManager.sharedInstance.hideLoader()
            
            let alertController = UIAlertController(title: "ERROR",
                                                    message: "No Page Found",
                                                    preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                
                _ = self.navigationController?.popViewController(animated: true)
                
            }
            
            alertController.addAction(cancelAction)
            
            let actualController = UtilityManager.sharedInstance.currentViewController()
            actualController.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    private func initMainWebView() {
        
        if mainWebView != nil {
            
            self.mainWebView.removeFromSuperview()
            self.mainWebView = nil
            
        }
        
        self.mainWebView = UIWebView.init(frame: UIScreen.main.bounds)
        self.mainWebView.delegate = self
        self.view.addSubview(mainWebView)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { (coordinator) in
            
            if UIDevice.current.orientation.isLandscape {
                
                print("Landscape")
                UtilityManager.sharedInstance.deviceRotated()
                self.initInterface()
                
            } else {
                
                print("Portrait")
                UtilityManager.sharedInstance.deviceRotated()
                self.initInterface()
                
            }
            
        }
        
    }
    
    //MARK - UIWebView Delegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        UtilityManager.sharedInstance.hideLoader()
        
    }
    
}
