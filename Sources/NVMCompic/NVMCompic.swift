import Foundation

public struct NVMCompic {
    public static let sharedInstance = NVMCompic()
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let fileManager = FileManager.default
    
    private var compicPath: URL?

    mutating public func initialize(compicPath: URL) {
        self.compicPath = compicPath
    }
    
    public func checkForUpdates() async throws {
        
    }
    
    /*public func getCompic(request: CompicRequest) async throws -> Compic {
        
    }*/
    
    public func checkImages() async throws {
        _ = try await self.checkImagesResult()
    }
    
    public func checkImagesResult() async throws -> ImageResult {
        if let compicPath = compicPath {
            if let localCompicPaths = try? fileManager.contentsOfDirectory(atPath: compicPath.path) {
                var localCompics: [Compic] = []
                for localCompicPath in localCompicPaths {
                    if let localCompicURL = URL(string: localCompicPath) {
                        let data: Data = try Data(contentsOf: localCompicURL)
                        let localCompic = try decoder.decode(Compic.self, from: data)
                        localCompics.append(localCompic)
                    }
                }
                
                let timeStamps = try await fetchCompicUpdatedTimeStamps(objectIds: Array(localCompics.map({ $0.objectId })))
                
                if !localCompics.isEmpty && !timeStamps.isEmpty {
                    let fetchableCompics = localCompics.filter { compic in
                        let localCompicTimeStamp = compic.updatedAt
                        if let cloudCompicTimeStamp = timeStamps[compic.objectId] {
                            return cloudCompicTimeStamp != localCompicTimeStamp
                        } else {
                            return true
                        }
                    }
                    
                    if !fetchableCompics.isEmpty {
                        let fetchedCompics = try await fetchCompicResults(requests: fetchableCompics.map({ $0.compicRequest }))
                        try await storeCompics(fetchedCompics)
                        
                        return .updated
                    } else {
                        return .none
                    }
                } else {
                    return .none
                }
            } else {
                return .none
            }
        } else {
            throw NVMCompicError.notInitialized
        }
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    public func fetchCompicResults(requests: [CompicRequest]) async throws -> [Compic] {
        let headers = ["content-type": "application/json"]
        var body: [String : Any] = [:]
        
        for request in requests {
            let requestData = try encoder.encode(request)
            if var requestDict = try JSONSerialization.jsonObject(with: requestData, options: .allowFragments) as? [String: Any] {
                if let requestUrl = (requestDict["url"] as? String)?.strippedUrl(keepPrefix: false, keepSuffix: true) {
                    requestDict.removeValue(forKey: "url")
                    
                    body[requestUrl] = requestDict
                }
            }
        }
        
        let finalBody = try JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: URL(string: "https://glacial-reaches-72317.herokuapp.com/api")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = finalBody
        
        let (data, response) = try await session.data(for: request)
        
        print("DATA: \(String(decoding: data, as: UTF8.self))")
        print("RESPONSE: \(response)")
        
        return try decoder.decode([Compic].self, from: data)
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    private func fetchCompicUpdatedTimeStamps(objectIds: [String]) async throws -> [String : Date] {
        let headers = ["content-type": "application/json"]
        
        let finalBody = try JSONSerialization.data(withJSONObject: objectIds)
        
        var request = URLRequest(url: URL(string: "https://glacial-reaches-72317.herokuapp.com/api")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = finalBody
        
        let (data, response) = try await session.data(for: request)
        
        print(String(decoding: data, as: UTF8.self))
        print(response)
        
        return try decoder.decode([String : Date].self, from: data)
    }
    
    private func storeCompics(_ compics: [Compic]) async throws {
        
    }
    
    public enum ImageType: String, Codable {
        case png = "png"
        case jpeg = "jpeg"
        case tiff = "tiff"
    }
    
    public enum ResizeType: String, Codable {
        /**
         Preserving aspect ratio, ensure the image covers both provided dimensions by cropping/clipping to fit.
         
         - note: This is the default
         */
        case cover = "cover"
        
        /**
         Preserving aspect ratio, contain within both provided dimensions using "letterboxing" where necessary.
         */
        case contain = "contain"
        
        /**
         Ignore the aspect ratio of the input and stretch to both provided dimensions.
         */
        case fill = "fill"
        
        /**
         Preserving aspect ratio, resize the image to be as large as possible while ensuring its dimensions are less than or equal to both those specified.
         */
        case inside = "inside"
        
        /**
         Preserving aspect ratio, resize the image to be as small as possible while ensuring its dimensions are greater than or equal to both those specified.
         */
        case outside = "outside"
    }
    
    public enum ImageResult {
        
        /**
         One or more icons are updated
         */
        case updated
        
        /**
         One or more icons are downloaded
         */
        case downloaded
        
        /**
         Multiple icons are either downloaded or updated
         */
        case both
        
        /**
         Icons are up-to-date
         */
        case none
    }
}

public struct Compic: Codable {
    public var objectId: String
    public var updatedAt: Date
    
    public var compicRequest: CompicRequest
    
    public var name: String
    public var url: String
    public var website: String
    public var countries: [String]
    
    public var iconImage: Data
    public var backgroundImage: Data
    public var cardImage: Data?
    
    public var tintColor: String?
    public var textColor: String?
    public var backgroundColor: String?
    public var buttonColor: String?
    public var fillColor: String?
    public var borderColor: String?
    public var headerColor: String?
    
    /**
     JSON Data of specific Novem variables
     
     - warning: U need a secret key to access this variable.
     */
    public var nvmData: Data?
}

public struct CompicRequest: Codable {
    public var url: String
     
    public var iconFormat: NVMCompic.ImageType?
    public var iconResizeType: NVMCompic.ResizeType?
    public var iconWidth: Int?
    public var iconHeight: Int?
    
    public var backgroundFormat: NVMCompic.ImageType?
    public var backgroundResizeType: NVMCompic.ResizeType?
    public var backgroundWidth: Int?
    public var backgroundHeight: Int?
    
    public var cardFormat: NVMCompic.ImageType?
    public var cardResizeType: NVMCompic.ResizeType?
    public var cardWidth: Int?
    public var cardHeight: Int?
    
    public init(url: String,
                
                iconFormat: NVMCompic.ImageType? = nil,
                iconResizeType: NVMCompic.ResizeType? = nil,
                iconWidth: Int? = nil,
                iconHeight: Int? = nil,
                
                backgroundFormat: NVMCompic.ImageType? = nil,
                backgroundResizeType: NVMCompic.ResizeType? = nil,
                backgroundWidth: Int? = nil,
                backgroundHeight: Int? = nil,
                
                cardFormat: NVMCompic.ImageType? = nil,
                cardResizeType: NVMCompic.ResizeType? = nil,
                cardWidth: Int? = nil,
                cardHeight: Int? = nil) {
        self.url = url
        
        self.iconFormat = iconFormat
        self.iconResizeType = iconResizeType
        self.iconWidth = iconWidth
        self.iconHeight = iconHeight
        
        self.backgroundFormat = backgroundFormat
        self.backgroundResizeType = backgroundResizeType
        self.backgroundWidth = backgroundWidth
        self.backgroundHeight = backgroundHeight
        
        self.cardFormat = cardFormat
        self.cardResizeType = cardResizeType
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
    }
}
