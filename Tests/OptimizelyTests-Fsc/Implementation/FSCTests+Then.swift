//
/****************************************************************************
* Copyright 2019, Optimizely, Inc. and contributors                        *
*                                                                          *
* Licensed under the Apache License, Version 2.0 (the "License");          *
* you may not use this file except in compliance with the License.         *
* You may obtain a copy of the License at                                  *
*                                                                          *
*    http://www.apache.org/licenses/LICENSE-2.0                            *
*                                                                          *
* Unless required by applicable law or agreed to in writing, software      *
* distributed under the License is distributed on an "AS IS" BASIS,        *
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
* See the License for the specific language governing permissions and      *
* limitations under the License.                                           *
***************************************************************************/
    

import XCTest
import Foundation
import Cucumberish

extension FSCTests {
    
    internal static func setupThenListeners() {
        
        Then("^the result should be (?:boolean )?\(Constants.optionalDoubleQuotedStringRegex)\(Constants.stringRegex)$") { (args, userInfo) -> Void in
            if let expected = (args?[0]) {
                switch requestModel?.api {
                case API.featureVariableBoolean.rawValue, API.featureVariableString.rawValue:
                    if let actual = responseModel?.result as? String {
                        XCTAssertEqual(expected, actual)
                    }
                    else {
                        XCTFail()
                    }
                    break
                case API.featureVariableDouble.rawValue:
                    if let _expected = Double(expected), let actual = responseModel?.result as? Double {
                        XCTAssertEqual(_expected, actual)
                    }
                    else {
                        XCTFail()
                    }
                    break
                case API.featureVariableInteger.rawValue:
                    if let _expected = Int(expected), let actual = responseModel?.result as? Int {
                        XCTAssertEqual(_expected, actual)
                    }
                    else {
                        XCTFail()
                    }
                    break
                default:
                    XCTFail()
                    break
                }
            }
            else {
                XCTFail()
            }
        }
    }
    
}