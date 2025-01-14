//
// Copyright 2019-2021, Optimizely, Inc. and contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import Optimizely

class SamplesForAPI {
    
    static func checkAPIs(optimizely: OptimizelyClient) {

        let attributes: [String: Any] = [
            "device": "iPhone",
            "lifetime": 24738388,
            "is_logged_in": true
            ]
        let tags: [String: Any] = [
            "category": "shoes",
            "count": 2
            ]

        // MARK: - activate

        do {
            let variationKey = try optimizely.activate(experimentKey: "my_experiment_key",
                                                       userId: "user_123",
                                                       attributes: attributes)
            print("[activate] \(variationKey)")
        } catch {
            print(error)
        }

        // MARK: - getVariationKey

        do {
            let variationKey = try optimizely.getVariationKey(experimentKey: "my_experiment_key",
                                                              userId: "user_123",
                                                              attributes: attributes)
            print("[getVariationKey] \(variationKey)")
        } catch {
            print(error)
        }

        // MARK: - getForcedVariation

        if let variationKey = optimizely.getForcedVariation(experimentKey: "my_experiment_key", userId: "user_123") {
            print("[getForcedVariation] \(variationKey)")
        }

        // MARK: - setForcedVariation

        if optimizely.setForcedVariation(experimentKey: "my_experiment_key",
                                         userId: "user_123",
                                         variationKey: "some_variation_key") {
            print("[setForcedVariation]")
        }

        // MARK: - isFeatureEnabled

        let enabled = optimizely.isFeatureEnabled(featureKey: "my_feature_key",
                                                          userId: "user_123",
                                                          attributes: attributes)
        print("[isFeatureEnabled] \(enabled)")

        // MARK: - getFeatureVariable

        do {
            let featureVariableValue = try optimizely.getFeatureVariableDouble(featureKey: "my_feature_key",
                                                                               variableKey: "double_variable_key",
                                                                               userId: "user_123",
                                                                               attributes: attributes)
            print("[getFeatureVariableDouble] \(featureVariableValue)")
        } catch {
            print(error)
        }

        // MARK: - getEnabledFeatures

        let enabledFeatures = optimizely.getEnabledFeatures(userId: "user_123", attributes: attributes)
        print("[getEnabledFeatures] \(enabledFeatures)")

        // MARK: - track

        do {
            try optimizely.track(eventKey: "my_purchase_event_key", userId: "user_123", attributes: attributes, eventTags: tags)
            print("[track]")
        } catch {
            print(error)
        }
        
    }
    
    // MARK: - OptimizelyUserContext (Decide API)
    
    static func checkOptimizelyUserContext(optimizely: OptimizelyClient) {
        let attributes: [String: Any] = [
            "location": "NY",
            "device": "iPhone",
            "lifetime": 24738388,
            "is_logged_in": true
            ]
        let tags: [String: Any] = [
            "category": "shoes",
            "count": 2
            ]

        let user = optimizely.createUserContext(userId: "user_123", attributes: attributes)
        
        let decision = user.decide(key: "show_coupon", options: [.includeReasons])
        
        if let variationKey = decision.variationKey {
            print("[decide] flag decision to variation: \(variationKey)")
            print("[decide] flag enabled: \(decision.enabled) with variables: \(decision.variables.toMap())")
            print("[decide] reasons: \(decision.reasons)")
        } else {
            print("[decide] error: \(decision.reasons)")
        }
        
        do {
            try user.trackEvent(eventKey: "my_purchase_event_key", eventTags: tags)
            print("[track] success")
        } catch {
            print("[track] error: \(error)")
        }
    }
    
    // MARK: - OptimizelyConfig
    
    static func checkOptimizelyConfig(optimizely: OptimizelyClient) {
        let optConfig = try! optimizely.getOptimizelyConfig()
        
        print("[OptimizelyConfig] revision = \(optConfig.revision)")

        //let experiments = optConfig.experimentsMap.values
        let experimentKeys = optConfig.experimentsMap.keys
        print("[OptimizelyConfig] all experiment keys = \(experimentKeys)")

        //let features = optConfig.featureFlagsMap.values
        let featureKeys = optConfig.featuresMap.keys
        print("[OptimizelyConfig] all feature keys = \(featureKeys)")

        // enumerate all experiments (variations, and associated variables)
        
        experimentKeys.forEach { expKey in
            print("[OptimizelyConfig] experimentKey = \(expKey)")
            
            let experiment = optConfig.experimentsMap[expKey]!
            
            let variationsMap = experiment.variationsMap
            let variationKeys = variationsMap.keys
            
            variationKeys.forEach { varKey in
                print("[OptimizelyConfig]   - variationKey = \(varKey)")
                
                let variation = variationsMap[varKey]!
                
                let variablesMap = variation.variablesMap
                let variableKeys = variablesMap.keys
                
                variableKeys.forEach { variableKey in
                    let variable = variablesMap[variableKey]!
                    
                    print("[OptimizelyConfig]       -- variable: \(variableKey), \(variable)")
                }
            }
        }
        
        // enumerate all features (experiments, variations, and assocated variables)
        
        featureKeys.forEach { featKey in
            print("[OptimizelyConfig] featureKey = \(featKey)")
            
            // enumerate feature experiments

            let feature = optConfig.featuresMap[featKey]!
            
            let experimentsMap = feature.experimentsMap
            let experimentKeys = experimentsMap.keys
            
            experimentKeys.forEach { expKey in
                print("[OptimizelyConfig]   - experimentKey = \(expKey)")
                
                let variationsMap = experimentsMap[expKey]!.variationsMap
                let variationKeys = variationsMap.keys
                
                variationKeys.forEach { varKey in
                    let variation = variationsMap[varKey]!
                    print("[OptimizelyConfig]       -- variation = { key: \(varKey), id: \(variation.id), featureEnabled: \(String(describing: variation.featureEnabled))")
                    
                    let variablesMap = variationsMap[varKey]!.variablesMap
                    let variableKeys = variablesMap.keys
                    
                    variableKeys.forEach { variableKey in
                        let variable = variablesMap[variableKey]!
                        
                        print("[OptimizelyConfig]           --- variable: \(variableKey), \(variable)")
                    }
                }
            }
            
            // enumerate all feature-variables

            let variablesMap = optConfig.featuresMap[featKey]!.variablesMap
            let variableKeys = variablesMap.keys
            
            variableKeys.forEach { variableKey in
                let variable = variablesMap[variableKey]!

                print("[OptimizelyConfig]   - (feature)variable: \(variableKey), \(variable)")
            }
        }
        
        // listen to NotificationType.datafileChange to get updated data

        _ = optimizely.notificationCenter?.addDatafileChangeNotificationListener { (_) in
            if let newOptConfig = try? optimizely.getOptimizelyConfig() {
                print("[OptimizelyConfig] revision = \(newOptConfig.revision)")
            }
        }

    }
    
    // MARK: - Initializations

    static func samplesForInitialization() {
        
        // These are sample codes for synchronous and asynchronous SDK initializations with multiple options

        guard let localDatafileUrl = Bundle.main.url(forResource: "demoTestDatafile", withExtension: "json"),
            let localDatafile = try? Data(contentsOf: localDatafileUrl)
        else {
            fatalError("Local datafile cannot be found")
        }

        var optimizely: OptimizelyClient
        var variationKey: String?
        
        // [Synchronous]
        
        // [S1] Synchronous initialization
        //      1. SDK is initialized instantly with a cached (or bundled) datafile
        //      2. A new datafile can be downloaded in background and cached after the SDK is initialized.
        //         The cached datafile will be used only when the SDK re-starts in the next session.
        optimizely = OptimizelyClient(sdkKey: "<Your_SDK_Key>")
        try? optimizely.start(datafile: localDatafile)
        variationKey = try? optimizely.activate(experimentKey: "<Experiment_Key", userId: "<User_ID>")
        
        // [S2] Synchronous initialization
        //      1. SDK is initialized instantly with a cached (or bundled) datafile
        //      2. A new datafile can be downloaded in background and cached after the SDK is initialized.
        //         The cached datafile is used immediately to update the SDK project config.
        optimizely = OptimizelyClient(sdkKey: "<Your_SDK_Key>")
        try? optimizely.start(datafile: localDatafile,
                              doUpdateConfigOnNewDatafile: true)
        variationKey = try? optimizely.activate(experimentKey: "<Experiment_Key", userId: "<User_ID>")
        
        // [S3] Synchronous initialization
        //      1. SDK is initialized instantly with a cached (or bundled) datafile
        //      2. A new datafile can be downloaded in background and cached after the SDK is initialized.
        //         The cached datafile is used immediately to update the SDK project config.
        //      3. Polling datafile periodically.
        //         The cached datafile is used immediately to update the SDK project config.
        optimizely = OptimizelyClient(sdkKey: "<Your_SDK_Key>",
                                      periodicDownloadInterval: 60)
        try? optimizely.start(datafile: localDatafile)
        variationKey = try? optimizely.activate(experimentKey: "<Experiment_Key", userId: "<User_ID>")
        
        // [Asynchronous]
        
        // [A1] Asynchronous initialization
        //      1. A datafile is downloaded from the server and the SDK is initialized with the datafile
        optimizely = OptimizelyClient(sdkKey: "<Your_SDK_Key>")
        optimizely.start { result in
            variationKey = try? optimizely.activate(experimentKey: "<Experiment_Key", userId: "<User_ID>")
        }
        
        // [A2] Asynchronous initialization
        //      1. A datafile is downloaded from the server and the SDK is initialized with the datafile
        //      2. Polling datafile periodically.
        //         The cached datafile is used immediately to update the SDK project config.
        optimizely = OptimizelyClient(sdkKey: "<Your_SDK_Key>",
                                      periodicDownloadInterval: 60)
        optimizely.start { result in
            variationKey = try? optimizely.activate(experimentKey: "<Experiment_Key", userId: "<User_ID>")
        }
        
        print("activated variation: \(String(describing: variationKey))")
    }

}
