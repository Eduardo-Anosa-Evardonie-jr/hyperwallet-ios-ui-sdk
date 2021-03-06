import Foundation
#if !COCOAPODS
import Common
#endif

/// Generates a mock Authentication Token
struct AuthenticationTokenGeneratorMock {
    private var userToken: String
    private var restUrl: String
    private var graphQlUrl: String
    private var minuteExpireIn: Int
    private let insightsUrl: String?
    private let environment: String?
    private let programModel: String?

    static var isConfigValid = true

    init(hostName: String = "localhost",
         minuteExpireIn: Int = 10,
         userToken: String = "YourUserToken",
         programModel: HyperwalletProgramModel) {
        self.restUrl = "https://\(hostName)/rest/v3/"
        self.graphQlUrl = "https://\(hostName)/graphql"
        self.minuteExpireIn = minuteExpireIn
        self.userToken = userToken
        self.insightsUrl = "http://insights.url"
        self.environment = "DEV"
        self.programModel = programModel.rawValue
    }

    init(programModel: String = "WALLET_MODEL",
         restUrl: String = "https://localhost/rest/v3/",
         graphQlUrl: String = "https://localhost/graphql") {
        self.restUrl = restUrl
        self.graphQlUrl = graphQlUrl
        self.minuteExpireIn = 10
        self.userToken = "YourUserToken"
        self.insightsUrl = "http://insights.url"
        self.environment = "DEV"
        self.programModel = programModel
    }

    /// Returns the Authentication Token
    var token: String {
        let headerBase64 = Data(header.utf8).base64EncodedString()
        let payloadBase64 = Data(payload.utf8).base64EncodedString()
        let signatureBase64 = Data("fake Signature".utf8).base64EncodedString()

        return "\(headerBase64).\(payloadBase64).\(signatureBase64)"
    }

    private var payload: String {
        guard AuthenticationTokenGeneratorMock.isConfigValid else {
            return #"{"broken_payload":"true"}"#
        }
        let currentDate = Date()
        let expireIn = buildFutureDate(baseDate: currentDate, minute: minuteExpireIn)
        return """
        {
        "sub": "\(userToken)",
        "iat": \(Int(currentDate.timeIntervalSince1970)),
        "exp": \(expireIn),
        "aud": "abc-00000-00000",
        "iss": "cbd-00000-00000",
        "rest-uri": "\(restUrl)",
        "graphql-uri": "\(graphQlUrl)",
        "insights-uri": "\(insightsUrl!)",
        "environment": "\(environment!)",
        "program-model": "\(programModel!)"
        }
        """
    }

    /// Returns the Authentication header
    private var header: String {
        return """
        {
        "alg": "ALGORITHM"
        }
        """
    }

    /// Generates the future date based at the attributes `baseDate` and `minute`
    private func buildFutureDate(baseDate: Date = Date(), minute: Int = 10) -> Int {
        var dateComponent = DateComponents()
        dateComponent.minute = minute

        guard  let expiredDate = Calendar.current.date(byAdding: dateComponent, to: baseDate) else {
            return 0
        }
        return Int(expiredDate.timeIntervalSince1970)
    }
}
