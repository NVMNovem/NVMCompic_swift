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
            try await NVMCompic.sharedInstance.checkImages()
            
            if settings.clearUnusedCompics != .never {
                try await NVMCompic.sharedInstance.checkCompicCache(settings.clearUnusedCompics)
            }
        }
    }
    
    internal func getCompicPath() throws -> URL {
        guard let compicPath = compicPath else { throw NVMCompicError.notInitialized }
        return compicPath
    }
    
    
    public func getCompic(request: CompicRequest) async throws -> Compic? {
        guard let compicFile = try await getCompicFile(request: request) else { return nil }
        return compicFile.compic(request: request)
    }
    public func getCompicFile(request: CompicRequest) async throws -> CompicFile? {
        guard let compicFiles = try await getCompicFiles(requests: [request]) else { return nil }
        if compicFiles.count == 1 {
            return compicFiles.first
        } else {
            return compicFiles.first { $0.compicRequest == request } //TODO: Moet beter
        }
    }
    public func getCompics(requests: [CompicRequest]) async throws -> [Compic]? {
        var allCompicFiles: [Compic] = []
        var fetchableCompicRequests: [CompicRequest] = []
        
        for request in requests {
            print("request: \(request)")
            if let localCompicFile = try getLocalCompicFile(request)?.compic(request: request) {
                allCompicFiles.append(localCompicFile)
            } else {
                fetchableCompicRequests.append(request)
            }
        }
        
        if !fetchableCompicRequests.isEmpty {
            let fetchedCompics = try await fetchCompicResults(requests: fetchableCompicRequests)
            for var fetchedCompic in fetchedCompics {
                print("fetchedCompic: \(fetchedCompic)")
                fetchedCompic.usedAt = Date()
                try fetchedCompic.save()
                
                allCompicFiles.append(fetchedCompic)
            }
        }
        
        if !allCompicFiles.isEmpty {
            return allCompicFiles
        } else {
            return nil
        }
    }
    public func getCompicFiles(requests: [CompicRequest]) async throws -> [CompicFile]? {
        var allCompicFiles: [CompicFile] = []
        var fetchableCompicRequests: [CompicRequest] = []
        
        for request in requests {
            if let localCompicFile = try getLocalCompicFile(request) {
                allCompicFiles.append(localCompicFile)
            } else {
                fetchableCompicRequests.append(request)
            }
        }
        
        if !fetchableCompicRequests.isEmpty {
            let fetchedCompics = try await fetchCompicResults(requests: fetchableCompicRequests)
            for var fetchedCompic in fetchedCompics {
                fetchedCompic.usedAt = Date()
                try fetchedCompic.save()
                
                allCompicFiles.append(try fetchedCompic.getCompicFile())
            }
        }
        
        if !allCompicFiles.isEmpty {
            return allCompicFiles
        } else {
            return nil
        }
    }
    
    public func checkImages() async throws {
        print("imageResults: \(try await self.checkImagesResult())")
    }
    
    public func checkImagesResult() async throws -> ImageResult {
        if let localCompics = try? getLocalCompicFiles(nil) {
            let timeStamps = try await fetchUpdatedAt(localCompics)
            
            if !localCompics.isEmpty && !timeStamps.isEmpty {
                let fetchableCompics = localCompics.filter { compic in
                    let localCompicTimeStamp = compic.updatedAt
                    if let cloudCompicTimeStamp = timeStamps[compic.url.toFileName] {
                        return cloudCompicTimeStamp != localCompicTimeStamp
                    } else {
                        return true
                    }
                }
                
                if !fetchableCompics.isEmpty {
                    let fetchedCompics = try await fetchCompicResults(requests: fetchableCompics.map({ $0.compicRequest }))
                    try storeCompics(fetchedCompics)
                    
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
    
    public func downloadCompics(requests: [CompicRequest]) async throws {
        try await storeCompics(fetchCompicResults(requests: requests))
    }
    
    private func fetchUpdatedAt(_ localCompics: [CompicFile]) async throws -> [String : Date] {
        var compicInfoRequests: [CompicInfoRequest] = []
        for localCompic in localCompics {
            compicInfoRequests.append(CompicInfoRequest(objectId: localCompic.objectId, type: .updatedAt, identifier: localCompic.url.toFileName))
        }
        
        let compicInfos = try await fetchCompicInfo(requests: compicInfoRequests)
        
        var updatedAts: [String : Date] = [:]
        for compicInfo in compicInfos {
            updatedAts[compicInfo.identifier ?? compicInfo.objectId] = compicInfo.updatedAt
        }
        
        return updatedAts
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    public func fetchCompicResults(requests: [CompicRequest]) async throws -> [Compic] {
        let headers = ["content-type": "application/json"]
        var body: [CompicRequest] = []
        
        //Remove duplicates
        //Try merging requests with same url (mss)
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
            
            do {
                decoder.dateDecodingStrategy = .nvmDateStrategySince1970
                return try decoder.decode([Compic].self, from: data)
            } catch let therror {
                throw therror
            }
        } else {
            throw NVMCompicError.invalidObject
        }
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    public func fetchCompicInfo(requests: [CompicInfoRequest]) async throws -> [CompicInfo] {
        if !requests.isEmpty {
            let headers = ["content-type": "application/json"]
            
            let requestData = try encoder.encode(requests)
            if let requestDict = try JSONSerialization.jsonObject(with: requestData, options: .allowFragments) as? [[String : String]] {
                let finalBody = try JSONSerialization.data(withJSONObject: requestDict)
                
                var request = URLRequest(url: URL(string: "https://compic.herokuapp.com/info")!)
                request.httpMethod = "POST"
                request.allHTTPHeaderFields = headers
                request.httpBody = finalBody
                
                let (data, _) = try await session.data(for: request)
                
                decoder.dateDecodingStrategy = .nvmDateStrategySince1970
                return try decoder.decode([CompicInfo].self, from: data)
            } else {
                throw NVMCompicError.invalidObject
            }
        } else {
            return []
        }
    }
    
    
    public func getLocalCompic(_ request: CompicRequest) throws -> Compic? {
        guard let localCompicFile = try self.getLocalCompicFile(request) else { return nil }
        print("getLocalCompic()")
        print(localCompicFile.compic(request: request))
        return localCompicFile.compic(request: request)
    }
    
    public func getLocalCompicFile(_ request: CompicRequest) throws -> CompicFile? {
        guard let compicPath = compicPath else { throw NVMCompicError.notInitialized }
        
        decoder.dateDecodingStrategy = .nvmDateStrategySince1970
        
        let compicFileURL = compicPath.appendingPathComponent(request.url.toFileName)
        
        if fileManager.fileExists(atPath: compicFileURL.path) {
            let compicFileData = try Data(contentsOf: compicFileURL)
            var compicFile = try decoder.decode(CompicFile.self, from: compicFileData)
            compicFile.usedAt = Date()
            try compicFile.save()
            
            return compicFile
        } else {
            return nil
        }
    }
    public func getLocalCompicFiles(_ requests: [CompicRequest]?) throws -> [CompicFile]? {
        guard let compicPath = compicPath else { throw NVMCompicError.notInitialized }
        
        decoder.dateDecodingStrategy = .nvmDateStrategySince1970
        
        if let requests = requests {
            var compicFiles: [CompicFile] = []
            for request in requests {
                let compicURL = compicPath.appendingPathComponent(request.url.toFileName)
                
                if fileManager.fileExists(atPath: compicPath.path) {
                    let compicData = try Data(contentsOf: compicURL)
                    var compicFile = try decoder.decode(CompicFile.self, from: compicData)
                    compicFile.usedAt = Date()
                    try compicFile.save()
                    
                    compicFiles.append(compicFile)
                }
            }
            
            if !compicFiles.isEmpty {
                return compicFiles
            } else {
                return nil
            }
        } else {
            if let localCompicFilesFilenames = try? fileManager.contentsOfDirectory(atPath: compicPath.path) {
                var localCompicFiles: [CompicFile] = []
                for localCompicFileFilename in localCompicFilesFilenames {
                    let localCompicURL = compicPath.appendingPathComponent(localCompicFileFilename)
                    let data: Data = try Data(contentsOf: localCompicURL)
                    let localCompicFile = try decoder.decode(CompicFile.self, from: data)
                    localCompicFiles.append(localCompicFile)
                }
                
                if !localCompicFiles.isEmpty {
                    return localCompicFiles
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    internal func storeCompics(_ compics: [Compic]) throws {
        for compic in compics {
            try compic.save()
        }
    }
    
    private func checkCompicCache(_ clearUnusedCompics: CompicSettings.After) async throws {
        guard let compicPath = compicPath else { throw NVMCompicError.notInitialized }

        let contents = try fileManager.contentsOfDirectory(atPath: compicPath.path)
        for compicFileName in contents {
            if compicFileName.hasSuffix(".compic") {
                let compicURL = compicPath.appendingPathComponent(compicFileName)
                
                if fileManager.fileExists(atPath: compicPath.path) {
                    if let compicData = try? Data(contentsOf: compicURL) {
                        let compic = try decoder.decode(Compic.self, from: compicData)
                        
                        switch clearUnusedCompics {
                        case .never:
                            break
                        case .week:
                            if daysBetweenDates(compic.storedAt, Date()) > 7 {
                                try fileManager.removeItem(at: compicURL)
                            }
                        case .month:
                            if daysBetweenDates(compic.storedAt, Date()) > 30 {
                                try fileManager.removeItem(at: compicURL)
                            }
                        case .year:
                            if daysBetweenDates(compic.storedAt, Date()) > 365 {
                                try fileManager.removeItem(at: compicURL)
                            }
                        }
                    }
                }
            }
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
