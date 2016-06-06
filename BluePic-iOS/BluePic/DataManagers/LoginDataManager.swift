/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit

enum LoginDataManagerError {

    //Error when there is a Facebook Authentication Error
    case FacebookAuthenticationError

    //Error when user canceled Facebook Login
    case UserCanceledLogin

    //Error when there is a connection failure
    case ConnectionFailure

}

class LoginDataManager: NSObject {

    /// Shared instance of data manager
    static let SharedInstance: LoginDataManager = {

        var manager = LoginDataManager()

        return manager

    }()

    /**
     Method will login the user into BluePic. It will first check if the user is already authenticated by checking if there is a user saved in NSUserDefaulted by called the isUserAlreadyAuthenticated method. If the user isn't already authenticated then it will call the FacebookDataManager's loginWithFacebook method

     - parameter callback: ((error : LoginDataManagerError?)->())
     */
    func login(callback : ((error: LoginDataManagerError?)->())) {

        ///Check if user is already authenticated from previous sesssions, aka check nsuserdefaults for user info
        if isUserAlreadyAuthenticated() {
            callback(error: nil)
        }
            //user not already authenticated from previous sessions
        else {

            //login with facebook
            FacebookDataManager.SharedInstance.loginWithFacebook({ (facebookUserId: String?, facebookUserFullName: String?, error: FacebookAuthenticationError?) in

                //facebook authentication failure
                if let error = error {

                    if error == FacebookAuthenticationError.UserCanceledLogin {
                        print(NSLocalizedString("Login Error: User Canceled Login", comment: ""))
                        callback(error: LoginDataManagerError.UserCanceledLogin)
                    } else {
                        print(NSLocalizedString("Login Error: Facebook Authentication Error", comment: ""))
                        callback(error: LoginDataManagerError.FacebookAuthenticationError)
                    }

                }
                //facebook authentication success
                else {

                    //Check to make sure facebook id and name aren't nil
                    if let facebookUserId = facebookUserId, facebookUserFullName = facebookUserFullName {

                        //try to register user with backend if the user doesn't already exist
                        BluemixDataManager.SharedInstance.checkIfUserAlreadyExistsIfNotCreateNewUser(facebookUserId, name: facebookUserFullName, callback: { success in

                            if success {
                                CurrentUser.willLoginLater = false
                                CurrentUser.facebookUserId = facebookUserId
                                CurrentUser.fullName = facebookUserFullName
                                callback(error: nil)
                            } else {
                                print(NSLocalizedString("Login Error: Connection Failure", comment: ""))
                                callback(error: LoginDataManagerError.ConnectionFailure )
                            }

                        })
                    }
                    //Facebook id and name were nil
                    else {
                        print(NSLocalizedString("Login Error: Facebook Authentication Error", comment: ""))
                        callback(error: LoginDataManagerError.FacebookAuthenticationError)
                    }
                }
            })
        }
    }

    /**
     Method is called when the user presses the sign in later button. It will sets the CurrentUser object's willLoginLater property to true
     */
    func loginLater() {

        CurrentUser.willLoginLater = true
    }

    /**
     Method will return true if the user is already authenticated or has pressed sign in later

     - returns: Bool
     */
    func isUserAuthenticatedOrPressedSignInLater() -> Bool {
        if isUserAlreadyAuthenticated() || CurrentUser.willLoginLater {
            return true
        } else {
           return false
        }
    }

    /**
     Method returns true if the user has already authenticated with facebook

     - returns: Bool
     */
    func isUserAlreadyAuthenticated() -> Bool {
        if CurrentUser.facebookUserId != "anonymous" && CurrentUser.fullName != "anonymous" {
            return true
        } else {
            return false
        }
    }

    func



    func tryToCreateAndSetCurrentUserAfterBeingChallengedInvokingASecureEndPoint() -> Bool {

        if let userIdentity = FacebookDataManager.SharedInstance.getFacebookUserIdentity(), facebookUserId = userIdentity.id, facebookUserFullName = userIdentity.displayName {

            BluemixDataManager.SharedInstance.createNewUser(facebookUserId, name: facebookUserFullName, result: { _ in

                
                


            })

            CurrentUser.facebookUserId = facebookUserId
            CurrentUser.fullName = facebookUserFullName

            return true

        } else {
            return false
        }

    }



}
