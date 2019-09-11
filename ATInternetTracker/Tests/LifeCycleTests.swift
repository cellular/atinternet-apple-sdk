/*
This SDK is licensed under the MIT license (MIT)
Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/





//
//  LifeCycleTests.swift
//  Tracker
//

import UIKit
import XCTest
@testable import Tracker


class LifeCycleTests: XCTestCase {

    var userDefaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    var now: String?
    
    override func setUp() {
        super.setUp()
        LifeCycle.parameters = .init()
        LifeCycle.appVersionChanged = false
        LifeCycle.daysSinceLastSession = 0
        LifeCycle.isInitialized = false

        dateFormatter.dateFormat = "yyyyMMdd"

        now = dateFormatter.string(from: Date())

        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.ApplicationUpdate.rawValue)
        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.FirstSession.rawValue)
        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.FirstSessionDate.rawValue)
        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.LastApplicationVersion.rawValue)
        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.LastSession.rawValue)
        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.SessionCount.rawValue)
        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.SessionCountSinceUpdate.rawValue)

        userDefaults.synchronize()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        LifeCycle.parameters = .init()
        LifeCycle.appVersionChanged = false
        LifeCycle.daysSinceLastSession = 0
        LifeCycle.isInitialized = false
        
        dateFormatter.dateFormat = "yyyyMMdd"
        now = dateFormatter.string(from: Date())
        
        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.ApplicationUpdate.rawValue)
        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.FirstSession.rawValue)
        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.FirstSessionDate.rawValue)
        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.LastApplicationVersion.rawValue)
        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.LastSession.rawValue)
        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.SessionCount.rawValue)
        userDefaults.removeObject(forKey: LifeCycle.LifeCycleKey.SessionCountSinceUpdate.rawValue)

        userDefaults.synchronize()
    }
    
    func testRetrieveSDKV1Lifecycle() {
        let now = Date()

        let oldLastUse = userDefaults.object(forKey: LifeCycle.LifeCycleKey.LastSessionV1.rawValue)
        
        XCTAssertNil(oldLastUse, "oldLastUse doit être nil")
        
        userDefaults.set("20110201", forKey: "firstLaunchDate")
        userDefaults.set(5, forKey: "ATLaunchCount")
        userDefaults.set(now, forKey: "lastUseDate")
        userDefaults.synchronize()

        LifeCycle.firstLaunchInit()
        
        XCTAssert(userDefaults.object(forKey: "firstLaunchDate") == nil, "firstSessionDate doit être nil")
        XCTAssert(userDefaults.object(forKey: LifeCycle.LifeCycleKey.FirstSession.rawValue) as! Int == 0, "firstSession doit être égale à 0")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
        XCTAssert((userDefaults.object(forKey: LifeCycle.LifeCycleKey.FirstSessionDate.rawValue) as? Date) == dateFormatter.date(from: "20110201"), "firstLaunchDate doit être égale à 20110201")
        XCTAssertNotNil(userDefaults.object(forKey: LifeCycle.LifeCycleKey.LastSession.rawValue) as? Date, "LastSession ne doit pas etre nil")
        XCTAssert(userDefaults.object(forKey: LifeCycle.LifeCycleKey.SessionCount.rawValue) as! Int == 6, "SessionCount doit être égale à 5")
    }

    func testFirstLaunchAndFirstScreenHit() {
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics(defaults: userDefaults)()
        let data = stringData.data(using: .utf8, allowLossyConversion: false)
        
        let json = ATJSON(data: data!)
        
        XCTAssert(json["lifecycle"]["fs"].intValue == 1, "la variable fs doit être égale à 1")
        XCTAssert(json["lifecycle"]["fsau"].intValue == 0, "la variable fsau doit être égale à 0")
        XCTAssert(json["lifecycle"]["fsd"].intValue == Int(now!), "la variable fsd doit être égale à aujourd'hui")
        XCTAssert(json["lifecycle"]["dsfs"].intValue == 0, "la variable dsfs doit être égale à 0")
        XCTAssert(json["lifecycle"]["dsls"].intValue == 0, "la variable dsls doit être égale à 0")
        XCTAssert(json["lifecycle"]["sc"].intValue == 1, "la variable sc doit être égale à 1")
    }
    
    func testDaysSinceFirstLaunch() {
        let today = Date()
        var dateComponent = DateComponents()
        dateComponent.day = -2

        let past = Calendar.current.date(byAdding: dateComponent, to: today)
        
        // Set first launch date two days in the past
        userDefaults.set(1, forKey: LifeCycle.LifeCycleKey.FirstSession.rawValue)
        userDefaults.set(past, forKey: LifeCycle.LifeCycleKey.FirstSessionDate.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
    
        let stringData = LifeCycle.getMetrics(defaults: userDefaults)()
        let data = stringData.data(using: .utf8, allowLossyConversion: false)
        
        let json = ATJSON(data: data!)

        XCTAssert(json["lifecycle"]["dsfs"].intValue == 2, "la variable dsfs doit être égale à 0")
    }
    
    func testDaysSinceLastSession() {
        let today = Date()
        var dateComponent = DateComponents()
        dateComponent.day = -10

        let past = Calendar.current.date(byAdding: dateComponent, to: today)
        
        // Set first launch date two days in the past
        userDefaults.set(1, forKey: LifeCycle.LifeCycleKey.FirstSession.rawValue)
        userDefaults.set(past, forKey: LifeCycle.LifeCycleKey.FirstSessionDate.rawValue)
        userDefaults.set(past, forKey: LifeCycle.LifeCycleKey.LastSession.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics(defaults: userDefaults)()
        let data = stringData.data(using: .utf8, allowLossyConversion: false)
        
        let json = ATJSON(data: data!)
        
        XCTAssert(json["lifecycle"]["dsls"].intValue == 10, "la variable fsdau doit être égale à 0")
    }
    
    func testSessionCount() {
        let today = Date()

        userDefaults.set(1, forKey: LifeCycle.LifeCycleKey.FirstSession.rawValue)
        userDefaults.set(today, forKey: LifeCycle.LifeCycleKey.FirstSessionDate.rawValue)
        userDefaults.set(10, forKey: LifeCycle.LifeCycleKey.SessionCount.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics(defaults: userDefaults)()
        let data = stringData.data(using: .utf8, allowLossyConversion: false)
        
        let json = ATJSON(data: data!)
        
        XCTAssert(json["lifecycle"]["sc"].intValue == 11, "la variable lc doit être égale à 11")
    }
    
    func testFirstSessionAfterUpdate() {
        let today = Date()
        userDefaults.set(1, forKey: LifeCycle.LifeCycleKey.FirstSession.rawValue)
        userDefaults.set(today, forKey: LifeCycle.LifeCycleKey.FirstSessionDate.rawValue)
        userDefaults.set("[0.0]", forKey: LifeCycle.LifeCycleKey.LastApplicationVersion.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics(defaults: userDefaults)()
        let data = stringData.data(using: .utf8, allowLossyConversion: false)
        
        let json = ATJSON(data: data!)
        
        XCTAssert(json["lifecycle"]["fsau"].intValue == 1, "la variable flai doit être égale à 1")
        XCTAssert(json["lifecycle"]["fsdau"].intValue == Int(now!), "la variable uld doit être égale à aujourd'hui")
        XCTAssert(json["lifecycle"]["scsu"].intValue == 1, "la variable lcsu doit être égale à 1")
        XCTAssert(json["lifecycle"]["dsu"].intValue == 0, "la variable dsu doit être égale à 0")
    }
    
    func testUpdateLaunchCount() {
        let today = Date()
        userDefaults.set(1, forKey: LifeCycle.LifeCycleKey.FirstSession.rawValue)
        userDefaults.set(today, forKey: LifeCycle.LifeCycleKey.FirstSessionDate.rawValue)
        userDefaults.set("", forKey: LifeCycle.LifeCycleKey.LastApplicationVersion.rawValue)
        userDefaults.set(10, forKey: LifeCycle.LifeCycleKey.SessionCountSinceUpdate.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics(defaults: userDefaults)()
        let data = stringData.data(using: .utf8, allowLossyConversion: false)
        
        let json = ATJSON(data: data!)
        
        XCTAssert(json["lifecycle"]["scsu"].intValue == 11, "la variable scsu doit être égale à 11")
    }
    
    func testDaysSinceUpdate() {
        let today = Date()
        var dateComponent = DateComponents()
        dateComponent.day = -7

        let past = Calendar.current.date(byAdding: dateComponent, to: today)
        
        userDefaults.set(past, forKey: LifeCycle.LifeCycleKey.ApplicationUpdate.rawValue)
        userDefaults.synchronize()
        
        _ = Tracker()
        
        let stringData = LifeCycle.getMetrics(defaults: userDefaults)()
        let data = stringData.data(using: .utf8, allowLossyConversion: false)
        
        let json = ATJSON(data: data!)
        
        XCTAssert(json["lifecycle"]["dsu"].intValue == 7, "la variable dsu doit être égale à 7")
    }
    
    func testSecondSinceBackground() {
        let now = Date()
        let nowWith65 = Date().addingTimeInterval(65)
        let delta = Tool.secondsBetweenDates(now, toDate: nowWith65)
        XCTAssert(delta == 65)
    }
    
    func testSwitchSessionIfMoreThan60Seconds() {
        _ = Tracker()

        let nowMinus65 = Date().addingTimeInterval( -65)
        LifeCycle.applicationActive(["sessionBackgroundDuration":"60"])
        let idSession = LifeCycle.sessionId
        
        LifeCycle.timeInBackground = nowMinus65
        LifeCycle.applicationActive(["sessionBackgroundDuration":"60"])
        XCTAssertNotEqual(LifeCycle.sessionId, idSession)
        
    }
    
    func testKeepSessionIfLessThan60Seconds() {
        _ = Tracker()
        let nowMinus65 = Date().addingTimeInterval(-35)
        LifeCycle.applicationActive(["sessionBackgroundDuration":"60"])
        let idSession = LifeCycle.sessionId
        
        LifeCycle.timeInBackground = nowMinus65
        LifeCycle.applicationActive(["sessionBackgroundDuration":"60"])
        XCTAssertEqual(LifeCycle.sessionId, idSession)
        
    }
    
}
