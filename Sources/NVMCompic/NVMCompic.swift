import Foundation

public struct NVMCompic {
    public static var sharedInstance = NVMCompic()
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let fileManager = FileManager.default
    
    private var compicPath: URL?

    mutating public func initialize(_ settings: CompicSettings) {
        self.compicPath = settings.compicPath
        
        Task.init {
            try await NVMCompic.sharedInstance.checkForUpdates()
            
            if settings.clearUnusedCompics != .never {
                try await NVMCompic.sharedInstance.checkCompicCache(settings.clearUnusedCompics)
            }
        }
    }
    
    public func checkForUpdates() async throws {
    }
    
    public func getCompic(request: CompicRequest) async throws -> Compic? {
        if let localCompic = try await getLocalCompic(request: request) {
            return localCompic
        } else {
            if var fetchedCompic = try await fetchCompicResults(requests: [request]).first(where: { $0.compicRequest == request }) {
                fetchedCompic.usedAt = Date()
                
                try await storeCompics([fetchedCompic])
                return fetchedCompic
            } else {
                return nil
            }
        }
    }
    
    public func getLocalCompic(request: CompicRequest) async throws -> Compic? {
        guard let localCompics = try await getLocalCompics([request]) else { return nil }
        return localCompics.first { $0.compicRequest == request }
    }
    
    public func checkImages() async throws {
        _ = try await self.checkImagesResult()
    }
    
    public func checkImagesResult() async throws -> ImageResult {
        guard let compicPath = compicPath else { throw NVMCompicError.notInitialized }
        
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
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    public func fetchCompicResults(requests: [CompicRequest]) async throws -> [Compic] {
        print("fetchCompicResults()")
        let headers = ["content-type": "application/json"]
        var body: [CompicRequest] = []
        for var compicRequest in requests {
            if let strippedUrl = compicRequest.url.strippedUrl(keepPrefix: false, keepSuffix: true) {
                compicRequest.url = strippedUrl
            }
            body.append(compicRequest)
        }
        
        let requestData = try encoder.encode(body)
        if let requestDict = try JSONSerialization.jsonObject(with: requestData, options: .allowFragments) as? [[String : Any]] {
            let finalBody = try JSONSerialization.data(withJSONObject: requestDict)
            
            var request = URLRequest(url: URL(string: "https://compic.herokuapp.com/api")!)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = finalBody
            
            let (data, _) = try await session.data(for: request)
            
            decoder.dateDecodingStrategy = .nvmDateStrategySince1970
            return try decoder.decode([Compic].self, from: data)
        } else {
            throw NVMCompicError.invalidObject
        }
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    private func fetchCompicUpdatedTimeStamps(objectIds: [String]) async throws -> [String : Date] {
        let headers = ["content-type": "application/json"]
        
        let finalBody = try JSONSerialization.data(withJSONObject: objectIds)
        
        var request = URLRequest(url: URL(string: "https://compic.herokuapp.com/api")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = finalBody
        
        let (data, response) = try await session.data(for: request)
        
        print(String(decoding: data, as: UTF8.self))
        print(response)
        
        return try decoder.decode([String : Date].self, from: data)
    }
    
    private func getLocalCompics(_ requests: [CompicRequest]) async throws -> [Compic]? {
        guard let compicPath = compicPath else { throw NVMCompicError.notInitialized }
        
        decoder.dateDecodingStrategy = .nvmDateStrategySince1970
        
        var compics: [Compic] = []
        for request in requests {
            let compicURL = compicPath.appendingPathComponent(request.getFileName())
            print(compicURL)
            if fileManager.fileExists(atPath: compicPath.path) {
                if let compicData = try? Data(contentsOf: compicURL) {
                    var compic = try decoder.decode(Compic.self, from: compicData)
                    compic.usedAt = Date()
                    
                    compics.append(compic)
                }
            }
        }
        
        if !compics.isEmpty {
            try await storeCompics(compics)
            return compics
        } else {
            return nil
        }
    }
    
    private func storeCompics(_ compics: [Compic]) async throws {
        guard let compicPath = compicPath else { throw NVMCompicError.notInitialized }
        
        encoder.dateEncodingStrategy = .nvmDateStrategySince1970
        
        for compic in compics {
            let compicData = try encoder.encode(compic)
            try compicData.write(to: compicPath.appendingPathComponent(compic.compicRequest.getFileName()))
        }
    }
    
    private func checkCompicCache(_ clearUnusedCompics: CompicSettings.After) async throws {
        guard let compicPath = compicPath else { throw NVMCompicError.notInitialized }

        let contents = try fileManager.contentsOfDirectory(atPath: compicPath.path)
        for compicURL in contents {
            print("checkCache: \(compicURL)")
            /*
            if fileManager.fileExists(atPath: compicPath.path) {
                if let compicData = try? Data(contentsOf: compicURL) {
                    var compic = try decoder.decode(Compic.self, from: compicData)
                    compic.usedAt = Date()
                    
                    compics.append(compic)
                }
            }
             */
        }
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
