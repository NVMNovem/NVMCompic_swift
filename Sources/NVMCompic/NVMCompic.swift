import Foundation
@available(iOS 15.0, macOS 12.0, *)
public struct NVMCompic {
    static private let session = URLSession.shared
    static private let decoder = JSONDecoder()

    public init() {
    }
    
    public static func getCompicResults() async throws -> Compic {
        let headers = ["content-type": "application/json"]
        let body : [String : Any] = ["url" : "2dehands.be",
                                     "icon_format" : "png",
                                     "background_width" : 100,
                                     "background_height" : 150,
                                     "background_format" : "png",
                                     "icon_width" : 200,
                                     "icon_height" : 200,
                                     "NVM_result" : true]
        let finalBody = try JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: URL(string: "https://glacial-reaches-72317.herokuapp.com/api")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = finalBody
        
        let (data, response) = try await session.data(for: request)
        
        print(String(decoding: data, as: UTF8.self))
        print(response)
        
        return try decoder.decode(Compic.self, from: data)
    }
    
    public enum ImageType: String {
        case png = "png"
        case jpeg = "jpeg"
        case tiff = "tiff"
    }
    
    public enum ResizeMode: String {
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
    var iconImage: Data
    var backgroundImage: Data
    var cardImage: Data?
    
    var tintColor: String?
    var textColor: String?
    var backgroundColor: String?
    var buttonColor: String?
    var fillColor: String?
}
