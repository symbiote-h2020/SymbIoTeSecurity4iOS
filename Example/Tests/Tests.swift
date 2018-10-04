import XCTest
import SymbioteIosUtils
import SymbioteSecurity4iOS

class Tests: XCTestCase {
    private static let AAMServerAddress: String = "https://symbiote-dev.man.poznan.pl/coreInterface"
    //private var keyStorePassword: String = "KEYSTORE_PASSWORD";
    private var icomUsername: String = "icom";
    private var icomPassword: String = "icom";
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
          logWarn("========login token = \(loginToken)")
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
    
}
