import Foundation

public struct NVMCompic {
    public static var sharedInstance = NVMCompic()
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let fileManager = FileManager.default
    
    private var compicPath: URL?
    
    private var compicFiles: [String : [CompicFile : Date]] = [:]

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
            return compicFiles.first { $0.allRequests().contains(request) }
        }
    }
    public func getCompics(requests: [CompicRequest]) async throws -> [Compic]? {
        var allCompicFiles: [Compic] = []
        var fetchableCompicRequests: [CompicRequest] = []
        
        for request in requests {
            if let localCompicFile = try getLocalCompicFile(request: request)?.compic(request: request) {
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
            if let localCompicFile = try getLocalCompicFile(request: request) {
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
    
    /**
     This will check all request for updates and download them if needed.
     
     - note: This function is meant to be executed on app launch.
    */
    public func checkCompics(requests: [CompicRequest]) async throws -> ImageResult {
        var imageResults: [ImageResult] = []
        
        var localCompicFiles: [CompicFile] = []
        var downloadableRequests: [CompicRequest] = []
        
        for request in requests {
            if let localCompic = try getLocalCompicFile(request: request) {
                localCompicFiles.append(localCompic)
            } else {
                downloadableRequests.append(request)
            }
        }
        
        if !localCompicFiles.isEmpty {
            let imageResult = try await self.updateCompicFiles(localCompicFiles)
            imageResults.append(imageResult)
        }
        if !downloadableRequests.isEmpty {
            try await self.downloadCompics(requests: downloadableRequests)
            imageResults.append(.downloaded)
        }
        
        if imageResults.count == 0 {
            return .none
        } else if imageResults.count >= 2 {
            return .both
        } else {
            return imageResults.first ?? .none
        }
    }
    
    /**
     This will check all local images and compare them with the cloud.
    */
    public func checkImages() async throws {
        _ = try await self.checkImagesResult()
    }
    
    /**
     This will check all local images and compare them with the cloud.
    */
    public func checkImagesResult() async throws -> ImageResult {
        if let localCompics = try? getLocalCompicFiles(requests: nil) {
            return try await updateCompicFiles(localCompics)
        } else {
            return .none
        }
    }
    
    public func updateCompicFiles(_ compicFiles: [CompicFile]) async throws -> ImageResult {
        let timeStamps = try await fetchUpdatedAt(compicFiles)
        
        if !compicFiles.isEmpty && !timeStamps.isEmpty {
            let fetchableCompics = compicFiles.filter { compic in
                let localCompicTimeStamp = compic.updatedAt
                if let cloudCompicTimeStamp = timeStamps[compic.url.toFileName] {
                    return cloudCompicTimeStamp != localCompicTimeStamp
                } else {
                    return true
                }
            }
            
            if !fetchableCompics.isEmpty {
                var fetchableCompicsRequests: [CompicRequest] = []
                for fetchableCompic in fetchableCompics {
                    fetchableCompicsRequests.append(contentsOf: fetchableCompic.allRequests())
                }
                
                if !fetchableCompicsRequests.isEmpty {
                    try await downloadCompics(requests: fetchableCompicsRequests)
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
            
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print ("NVMCompic Service Unavailable: \(httpResponse.statusCode)")
                
                throw NVMCompicError.serviceUnavailable
            } else {
                do {
                    decoder.dateDecodingStrategy = .nvmDateStrategySince1970
                    return try decoder.decode([Compic].self, from: data)
                } catch let therror {
                    throw therror
                }
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
        guard let localCompicFile = try self.getLocalCompicFile(request: request) else { return nil }
        
        return localCompicFile.compic(request: request)
    }
    
    /**
     Use this to return a **CompicFile** based on the url.
     
     - Returns: A CompicFile if a CompicFile has been found wich mathes the url.
     */
    public mutating func getLocalCompicFile(url: String) throws -> CompicFile? {
        guard let compicPath = compicPath else { throw NVMCompicError.notInitialized }
        guard let strippedUrl = url.strippedUrl(keepPrefix: false, keepSuffix: true) else { throw NVMCompicError.invalidUrl }
        
        if let siCompicFiles = self.compicFiles[strippedUrl] {
            for siCompicFile in siCompicFiles {
                if secondsBetweenDates(siCompicFile.value, Date()) <= 1 {
                    return siCompicFile.key
                }
            }
        }
        
        decoder.dateDecodingStrategy = .nvmDateStrategySince1970
        
        let compicFileURL = compicPath.appendingPathComponent(strippedUrl.toFileName)
        
        if fileManager.fileExists(atPath: compicFileURL.path) {
            let compicFileData = try Data(contentsOf: compicFileURL)
            var compicFile = try decoder.decode(CompicFile.self, from: compicFileData)
            
            compicFile.usedAt = Date()
            try compicFile.save()
            
            self.compicFiles[strippedUrl] = [compicFile : Date()]
            
            return compicFile
        } else {
            return nil
        }
    }
    /**
     Use this to return a **CompicFile** only if it contains the request.
     
     - Returns: A CompicFile if a CompicFile has been found wich contains the request. Returns nil if no match is found.
     */
    public func getLocalCompicFile(request: CompicRequest) throws -> CompicFile? {
        guard let compicPath = compicPath else { throw NVMCompicError.notInitialized }
        
        decoder.dateDecodingStrategy = .nvmDateStrategySince1970
        
        let compicFileURL = compicPath.appendingPathComponent(request.url.toFileName)
        
        if fileManager.fileExists(atPath: compicFileURL.path) {
            let compicFileData = try Data(contentsOf: compicFileURL)
            var compicFile = try decoder.decode(CompicFile.self, from: compicFileData)
            
            if compicFile.allRequests().contains(request) {
                compicFile.usedAt = Date()
                try compicFile.save()
                
                return compicFile
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    /**
     Use this to return a collection of **CompicFile**s based on the urls.
     
     - Returns: A CompicFile collection if a CompicFile has been found wich mathes the url.
                Returns all local CompicFiles if no urls are given.
     */
    public func getLocalCompicFiles(urls: [String]?) throws -> [CompicFile]? {
        guard let compicPath = compicPath else { throw NVMCompicError.notInitialized }
        
        decoder.dateDecodingStrategy = .nvmDateStrategySince1970
        
        if let urls = urls {
            var compicFiles: [CompicFile] = []
            for url in urls {
                if let strippedUrl = url.strippedUrl(keepPrefix: false, keepSuffix: true) {
                    let compicURL = compicPath.appendingPathComponent(strippedUrl.toFileName)
                    
                    if fileManager.fileExists(atPath: compicPath.path) {
                        let compicData = try Data(contentsOf: compicURL)
                        var compicFile = try decoder.decode(CompicFile.self, from: compicData)
                        
                        compicFile.usedAt = Date()
                        try compicFile.save()
                        
                        compicFiles.append(compicFile)
                    }
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
    /**
     Use this to return a collection of **CompicFile**s only if it contains the request.
     
     - Returns: A CompicFile collection if a CompicFile has been found wich contains the request. Returns nil if no match is found.
                Returns all local CompicFiles if no requests are given.
     */
    public func getLocalCompicFiles(requests: [CompicRequest]?) throws -> [CompicFile]? {
        guard let compicPath = compicPath else { throw NVMCompicError.notInitialized }
        
        decoder.dateDecodingStrategy = .nvmDateStrategySince1970
        
        if let requests = requests {
            var compicFiles: [CompicFile] = []
            for request in requests {
                let compicURL = compicPath.appendingPathComponent(request.url.toFileName)
                
                if fileManager.fileExists(atPath: compicPath.path) {
                    let compicData = try Data(contentsOf: compicURL)
                    var compicFile = try decoder.decode(CompicFile.self, from: compicData)
                    
                    if compicFile.allRequests().contains(request) {
                        compicFile.usedAt = Date()
                        try compicFile.save()
                        
                        compicFiles.append(compicFile)
                    }
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
         If website is tileable, it will contain the image within both provided dimensions using "letterboxing" where necessary.
         Else it will use **cover**.
         */
        case tileCover = "nvmTile?cover"
        
        /**
         If website is tileable, it will contain the image within both provided dimensions using "letterboxing" where necessary.
         Else it will use **fill**.
         */
        case tileFill = "nvmTile?fill"
        
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
