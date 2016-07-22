//
//  ViewController.swift
//  PokemonGoSwiftAPI
//
//  Created by Amit Palomo on 19/07/2016.
//  Copyright © 2016 Amit Palomo.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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

