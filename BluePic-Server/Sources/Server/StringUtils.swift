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

import Foundation
import LoggerAPI

public struct StringUtils {

  /**
   Strips out any Url encoded whitespace and replaces it with a human readable space
   
   - parameter str: String to parse
   
   - returns: decoded string without whitespace encodings
   */
  static func decodeWhiteSpace(inString str: String) -> String {
    let decodedStr = str.replacingOccurrences(of: "%20", with: " ")
    Log.verbose("Decoded (whitespace) in string: '\(str)' to '\(decodedStr)'.")
    return decodedStr
  }

  /**
   Generates timestamp in specific format
   
   - returns: timestamp in String form
   */
  static func currentTimestamp() -> String {
    #if os(Linux)
    let dateStr = NSDate().descriptionWithLocale(nil).bridge()
    #else
    let dateStr = NSDate().description.bridge()
    #endif
    let ts = dateStr.substring(to: 10) + "T" + dateStr.substring(with: NSRange(location: 11, length: 8))
    Log.verbose("Current time string: \(dateStr)")
    Log.verbose("Current timestamp generated: \(ts)")
    return ts
  }

}
