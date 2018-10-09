import XCTest
import SymbioteIosUtils
import SymbioteSecurity4iOS

class Tests: XCTestCase {
    private static let AAMServerAddress: String = "https://symbiote-open.man.poznan.pl/coreInterface"
    //private var keyStorePassword: String = "KEYSTORE_PASSWORD";
    private var icomUsername: String = "icom";
    private var icomPassword: String = "icom";
//    private var icomUsername: String = "konrri"; //this user cennot login, so the test will fail
//    private var icomPassword: String = "konrri";
    private var platformId: String = "SymbIoTe_Core_AAM";
    private var clientId: String = "1ef55ca2-206a-11e8-b467-0ed5f89f718b";
    //private var keyStoreFilename: String = "/keystore.jks";
    private var clientSH: SecurityHandler = SecurityHandler(homeAAMAddress: Tests.AAMServerAddress)
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    ///many steps of getting access with security home token
    func testGetSecurityRequest() {
        let aams = clientSH.getAvailableAams()
        XCTAssertTrue(aams.count >= 1 , "There are no AAMs just after method")
        log("clientSH.getAvailableAams() finished")
        if waitForNotificationNamed(SymNotificationName.CoreCommunictation.rawValue) {
            log("clientSH posted notification")
            XCTAssertTrue(clientSH.availableAams.count >= 1 , "There are no AAMs in public property")
        }
        
        let coreAam = clientSH.getCoreAAMInstance()
        if let coreAamAddress = coreAam?.aamAddress {
            log("coreAam.aamAddress=\(coreAamAddress)")
            XCTAssert(coreAamAddress.hasPrefix(Tests.AAMServerAddress), "Unexpected address of CoreAAM")
        }
        
        if let homeAam = coreAam {
           let certStr = clientSH.getCertificate(aam: homeAam, username: icomUsername, password: icomPassword, clientId: "clientId")  //motyla noga - czy tu ma być "clientId"
           XCTAssert(certStr.hasPrefix("-----BEGIN CERTIFICATE-----"), "Wrong certificate string ")
            
            let loginToken = clientSH.login(homeAam)
            guard let homeToken = loginToken else {
                XCTFail("home token == nil")
                return
            }
            logWarn("========login token = \(homeToken.token)")
            XCTAssert(homeToken.token.count > 10, "HomeToken string should be long")
            XCTAssert(homeToken.authenticationChallenge.count > 10, "authenticationChallenge string should be long")
        }
    }
    
    
    func testGuestAccess() {
        let coreAam = clientSH.getCoreAAMInstance()
        if let aam = coreAam {
            let token = clientSH.loginAsGuest(aam)
            XCTAssert(token.count > 10, "GuestToken string should be long")
            
        }
        else {
            XCTFail("No core AAM")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func waitForNotificationNamed(_ notificationName: String) -> Bool {
        let notiName = NSNotification.Name(notificationName)
        let expectation = XCTNSNotificationExpectation(name: notiName)
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        log("waitForNotificationNamed result = \(result.rawValue)")
        return result == .completed
    }
    
    func testJwtDecode() {
        let token = "eyJhbGciOiJFUzI1NiJ9.eyJ0dHlwIjoiSE9NRSIsInN1YiI6Imljb21AenVwYV9rb25ycmlfenVwYSIsImlwayI6Ik1Ga3dFd1lIS29aSXpqMENBUVlJS29aSXpqMERBUWNEUWdBRVBXRGQzNnllcXVFWm8zUzh3SXZNL1ZmK1F3SE9pK01FMVN2RmIvcG5hVjdQRFJKOEU2ZnVpeXg1ZTlrZVhra0diRFVVTDlJcU54QnJJQ3dvQkJUU0NnPT0iLCJpc3MiOiJTeW1iSW9UZV9Db3JlX0FBTSIsImV4cCI6MTUzOTAwMjU1NSwiaWF0IjoxNTM5MDAyNDk1LCJqdGkiOiIyMDI2NTI0MTY4Iiwic3BrIjoiTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFdTdYck9QR3AwVDFaSlhoVnlOcXJNZ2RhRmJXSi8zVHZXTGdJZEp4OXRGNk1MaWEvL2YydVJNL05SaTF2TFloUUdoeU1SV1pScGFZOWcxUzFlRjhHWnc9PSJ9.KY1qmH54nhmErWSJ6nY7yoeVlFOWGXu_PI3zpRaqI7u6s9Wk-rQVbWajCGndlMXMBcqTzPb3g_6N-kgZjl2nQA"
        
        let result = JWT.decode(token: token)
        
        log("")
    }
    
    func testAuthChallenge() {
        let inStr = "eyJhbGciOiJFUzI1NiJ9.eyJ0dHlwIjoiSE9NRSIsInN1YiI6InJoIiwiaXBrIjoiTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFN2VTYUlicWNRSnNpUWRmRXpPWkZuZlVQZWpTSkpDb1R4SSt2YWZiS1dyclZSUVNkS3cwdlYvUmRkZ3U1SXhWTnFkV0tsa3dpcldsTVpYTFJHcWZ3aHc9PSIsImlzcyI6InBsYXRmb3JtLTEiLCJleHAiOjE1MTk3MjM0NTUsImlhdCI6MTUxOTcyMzQ1MywianRpIjoiMTY0ODE2NzgxNiIsInNwayI6Ik1Ga3dFd1lIS29aSXpqMENBUVlJS29aSXpqMERBUWNEUWdBRWVwK1VPTHFVbGRuamJwL0V4UGNpNHV3ZDk0bzRpczM0SXFCYmlhS2VmMXlPd2hUQ2wzcEw2Y1ErNXhRMFN5ajd2NEtscngvamRVUEhGN2dpQktUVnVBPT0ifQ.82rEpMSdLs3VFfsrKkS17wjtnP5A2dZm8J70CG-YNrp-GwvDeRSj1DJiR0qKYfu5oOm5-cTsqJm7UGVjZaorCQ" + "1519723453000"
        let sha = sha256(inStr)
        log("==========   sha256=")
        log(sha)
        
        //should be 3f6922d00d31f66ae9a7845eb364af5e7e383fd06841a33daee6fe5e489e2523
    }
    
}
