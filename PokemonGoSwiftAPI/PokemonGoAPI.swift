//
//  PokemonGoAPI.swift
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

import Foundation
import Alamofire

typealias JSONObject = [String: AnyObject]
typealias PokemonGoToken = String

public class PokemonGoAPI {
    
    static let sharedInstance = PokemonGoAPI()

    static let PTC_LOGIN_URL = "https://sso.pokemon.com/sso/login?service=https%3A%2F%2Fsso.pokemon.com%2Fsso%2Foauth2.0%2FcallbackAuthorize"
    static let PTC_LOGIN_OAUTH = "https://sso.pokemon.com/sso/oauth2.0/accessToken"
    static let PTC_LOGIN_CLIENT_SECRET = "w8ScCUXJQc6kXKw8FiOhd8Fixzht18Dq3PEVkUCP5ZPxtgyWsbTvWHFLm2wNY0JR"
    
    func login(username: String, password: String, completion: (PokemonGoToken?, NSError?) -> ()) {
        
        let loginURL = NSURL(string: PokemonGoAPI.PTC_LOGIN_URL)!

        // phase1
        Alamofire.request(.GET,
        loginURL,
        parameters: nil,
        encoding: .URL,
        headers: nil)
        .validate()
        .responseJSON { response in
                
            switch response.result {
            case .Success:
                break
            case .Failure(let error):
                print("Request failed with error: \(error)")
                if let data = response.data {
                    print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                }
                completion(nil, error)
            }
                
            guard let json = response.result.value as? JSONObject,
                let lt = json["lt"] as? String,
                let execution = json["execution"] as? String
                else {
                    let error = NSError.errorWithCode(NSURLErrorCannotParseResponse,
                                                    failureReason: "Expecting a JSON object")
                    completion(nil, error)
                    return
                }
            
            let params = [
                "lt": lt,
                "execution": execution,
                "_eventId": "submit",
                "username": username,
                "password": password
            ]
            
            // phase2
            Alamofire.request(.POST,
            loginURL,
            parameters: params,
            encoding: .URL,
            headers: nil)
            .validate()
            .responseJSON { response in
                
                guard let response = response.response,
                    let range = response.URL!.URLString.rangeOfString(".*ticket=", options: .RegularExpressionSearch)
                    else {
                        let error = NSError.errorWithCode(NSURLErrorCannotParseResponse,
                            failureReason: "Expecting a ticket. Probably wrong username or password")
                        completion(nil, error)
                        return
                }
                
                let ticket = response.URL!.URLString.substringFromIndex(range.endIndex)
                let oauthURL = NSURL(string: PokemonGoAPI.PTC_LOGIN_OAUTH)!
                let params2 = [
                    "client_id": "mobile-app_pokemon-go",
                    "redirect_uri": "https://www.nianticlabs.com/pokemongo/error",
                    "client_secret": PokemonGoAPI.PTC_LOGIN_CLIENT_SECRET,
                    "grant_type": "refresh_token",
                    "code": ticket
                ]
                
                // phase3
                Alamofire.request(.POST,
                oauthURL,
                parameters: params2,
                encoding: .URL,
                headers: nil)
                .responseString { response in
                    
                    if let tokenString = response.result.value {
                        var range = tokenString.rangeOfString("access_token=", options: .RegularExpressionSearch)
                        var token = tokenString.substringFromIndex(range!.endIndex)
                        range = token.rangeOfString("&expires", options: .RegularExpressionSearch)
                        token = token.substringToIndex(range!.startIndex)
                        completion(token, nil)
                    }
                    
                }
            }
            
            
        }
        
    }
    
}


extension NSError {

    static func errorWithCode(code: Int, failureReason: String) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        return NSError(domain: "pokemongoswiftapi.catch.em", code: code, userInfo: userInfo)
    }


}


