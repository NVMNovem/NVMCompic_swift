import Foundation
@available(iOS 15.0, macOS 12.0, *)
public struct NVMCompic {
    static private let session = URLSession.shared
    static private let decoder = JSONDecoder()
    static private let encoder = JSONEncoder()

    public init() {
    }
    
    public static func getCompicResults(requests: [CompicRequest]) async throws -> Compic {
        let headers = ["content-type": "application/json"]
        let body = try encoder.encode(requests)
        
        var request = URLRequest(url: URL(string: "https://glacial-reaches-72317.herokuapp.com/api")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        print(String(decoding: data, as: UTF8.self))
        print(response)
        
        return try decoder.decode(Compic.self, from: data)
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
}

public struct Compic: Codable {
    public var iconImage: Data
    public var backgroundImage: Data
    public var cardImage: Data?
    
    public var tintColor: String?
    public var textColor: String?
    public var backgroundColor: String?
    public var buttonColor: String?
    public var fillColor: String?
    public var borderColor: String?
}

public struct CompicRequest: Codable {
    public var url: String
     
    public var iconFormat: NVMCompic.ImageType?
    public var iconResizeType: NVMCompic.ResizeType?
    public var iconWidth: NVMCompic.ImageType?
    public var iconHeight: NVMCompic.ImageType?
    
    public var backgroundFormat: NVMCompic.ImageType?
    public var backgroundResizeType: NVMCompic.ResizeType?
    public var backgroundWidth: NVMCompic.ImageType?
    public var backgroundHeight: NVMCompic.ImageType?
    
    public var cardFormat: NVMCompic.ImageType?
    public var cardResizeType: NVMCompic.ResizeType?
    public var cardWidth: NVMCompic.ImageType?
    public var cardHeight: NVMCompic.ImageType?
}
