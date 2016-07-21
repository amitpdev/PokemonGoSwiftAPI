//
//  ViewController.swift
//  PokemonGoSwiftAPI
//
//  Created by Amit Palomo on 19/07/2016.
//  Copyright © 2016 Amit Palomo. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = 5
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        guard
            let username = usernameTextField.text,
            let password = passwordTextField.text
        where
            username.characters.count > 0 &&
            password.characters.count > 0
        else {
            return
        }
        
        PokemonGoAPI.sharedInstance.login(username, password: password) { token, error in
            
            if let token = token where error == nil {
                print("Yoohoo you've just logged in. your token is: \(token)")
            }
            else {
                print("An error has occured: \(error!.localizedDescription)")
            }
            
        }

    }

}

