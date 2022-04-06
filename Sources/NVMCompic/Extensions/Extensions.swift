//
//  Extensions.swift
//  
//
//  Created by Damian Van de Kauter on 15/03/2022.
//

import Foundation

internal extension String {
    func strippedUrl(keepPrefix: Bool, keepSuffix: Bool = true) -> String? {
        if !self.isEmpty {
            var theUrlString: String = self
            if ((!self.contains("http://")) && (!self.contains("https://"))) {
                theUrlString = "https://" + self
            }
            
            if let theUrl = URL(string: theUrlString) {
                if let theStrippedString = theUrl.host {
                    if !theStrippedString.isEmpty {
                        if keepPrefix {
                            if keepSuffix {
                                return theStrippedString
                            } else {
                                if let lastDotRange = theStrippedString.range(of: ".", options: .backwards) {
                                    var suffixLessString = theStrippedString
                                    suffixLessString.removeSubrange(lastDotRange.lowerBound..<theStrippedString.endIndex)
                                    return suffixLessString
                                } else {
                                    return theStrippedString
                                }
                            }
                        } else {
                            if theStrippedString.countInstances(of: ".") >= 4 {
                                if let firstDotRange = theStrippedString.range(of: ".") {
                                    var firstStrip = theStrippedString
                                    firstStrip.removeSubrange(theStrippedString.startIndex..<firstDotRange.upperBound)
                                    if let secondDotRange = firstStrip.range(of: ".") {
                                        var secondStrip = firstStrip
                                        secondStrip.removeSubrange(firstStrip.startIndex..<secondDotRange.upperBound)
                                        if let thirdDotRange = secondStrip.range(of: ".") {
                                            var thirdStrip = secondStrip
                                            thirdStrip.removeSubrange(secondStrip.startIndex..<thirdDotRange.upperBound)
                                            if keepSuffix {
                                                return thirdStrip
                                            } else {
                                                if let lastDotRange = thirdStrip.range(of: ".", options: .backwards) {
                                                    var suffixLessString = thirdStrip
                                                    suffixLessString.removeSubrange(lastDotRange.lowerBound..<thirdStrip.endIndex)
                                                    return suffixLessString
                                                } else {
                                                    return thirdStrip
                                                }
                                            }
                                        } else {
                                            if keepSuffix {
                                                return secondStrip
                                            } else {
                                                if let lastDotRange = secondStrip.range(of: ".", options: .backwards) {
                                                    var suffixLessString = secondStrip
                                                    suffixLessString.removeSubrange(lastDotRange.lowerBound..<secondStrip.endIndex)
                                                    return suffixLessString
                                                } else {
                                                    return secondStrip
                                                }
                                            }
                                        }
                                    } else {
                                        if keepSuffix {
                                            return firstStrip
                                        } else {
                                            if let lastDotRange = firstStrip.range(of: ".", options: .backwards) {
                                                var suffixLessString = firstStrip
                                                suffixLessString.removeSubrange(lastDotRange.lowerBound..<firstStrip.endIndex)
                                                return suffixLessString
                                            } else {
                                                return firstStrip
                                            }
                                        }
                                    }
                                } else {
                                    if keepSuffix {
                                        return theStrippedString
                                    } else {
                                        if let lastDotRange = theStrippedString.range(of: ".", options: .backwards) {
                                            var suffixLessString = theStrippedString
                                            suffixLessString.removeSubrange(lastDotRange.lowerBound..<theStrippedString.endIndex)
                                            return suffixLessString
                                        } else {
                                            return theStrippedString
                                        }
                                    }
                                }
                            } else if theStrippedString.countInstances(of: ".") >= 3 {
                                if let firstDotRange = theStrippedString.range(of: ".") {
                                    var firstStrip = theStrippedString
                                    firstStrip.removeSubrange(theStrippedString.startIndex..<firstDotRange.upperBound)
                                    if let secondDotRange = firstStrip.range(of: ".") {
                                        var secondStrip = firstStrip
                                        secondStrip.removeSubrange(firstStrip.startIndex..<secondDotRange.upperBound)
                                        if keepSuffix {
                                            return secondStrip
                                        } else {
                                            if let lastDotRange = secondStrip.range(of: ".", options: .backwards) {
                                                var suffixLessString = secondStrip
                                                suffixLessString.removeSubrange(lastDotRange.lowerBound..<secondStrip.endIndex)
                                                return suffixLessString
                                            } else {
                                                return secondStrip
                                            }
                                        }
                                    } else {
                                        if keepSuffix {
                                            return firstStrip
                                        } else {
                                            if let lastDotRange = firstStrip.range(of: ".", options: .backwards) {
                                                var suffixLessString = firstStrip
                                                suffixLessString.removeSubrange(lastDotRange.lowerBound..<firstStrip.endIndex)
                                                return suffixLessString
                                            } else {
                                                return firstStrip
                                            }
                                        }
                                    }
                                } else {
                                    if keepSuffix {
                                        return theStrippedString
                                    } else {
                                        if let lastDotRange = theStrippedString.range(of: ".", options: .backwards) {
                                            var suffixLessString = theStrippedString
                                            suffixLessString.removeSubrange(lastDotRange.lowerBound..<theStrippedString.endIndex)
                                            return suffixLessString
                                        } else {
                                            return theStrippedString
                                        }
                                    }
                                }
                            } else if theStrippedString.countInstances(of: ".") >= 2 {
                                if let firstDotRange = theStrippedString.range(of: ".") {
                                    var firstStrip = theStrippedString
                                    firstStrip.removeSubrange(theStrippedString.startIndex..<firstDotRange.upperBound)
                                    if keepSuffix {
                                        return firstStrip
                                    } else {
                                        if let lastDotRange = firstStrip.range(of: ".", options: .backwards) {
                                            var suffixLessString = firstStrip
                                            suffixLessString.removeSubrange(lastDotRange.lowerBound..<firstStrip.endIndex)
                                            return suffixLessString
                                        } else {
                                            return firstStrip
                                        }
                                    }
                                } else {
                                    if keepSuffix {
                                        return theStrippedString
                                    } else {
                                        if let lastDotRange = theStrippedString.range(of: ".", options: .backwards) {
                                            var suffixLessString = theStrippedString
                                            suffixLessString.removeSubrange(lastDotRange.lowerBound..<theStrippedString.endIndex)
                                            return suffixLessString
                                        } else {
                                            return theStrippedString
                                        }
                                    }
                                }
                            } else {
                                if keepSuffix {
                                    return theStrippedString
                                } else {
                                    if let lastDotRange = theStrippedString.range(of: ".", options: .backwards) {
                                        var suffixLessString = theStrippedString
                                        suffixLessString.removeSubrange(lastDotRange.lowerBound..<theStrippedString.endIndex)
                                        return suffixLessString
                                    } else {
                                        return theStrippedString
                                    }
                                }
                            }
                        }
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func countInstances(of string: String) -> Int {
        assert(!string.isEmpty)
        var count = 0
        var searchRange: Range<String.Index>?
        while let foundRange = range(of: string, options: [], range: searchRange) {
            count += 1
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return count
    }
}

internal extension JSONDecoder.DateDecodingStrategy {
    static let nvmDateStrategySince1970 = custom {
        do {
            let container = try $0.singleValueContainer()
            do {
                let secondsSince1970 = try container.decode(Int.self)
                return date(from: secondsSince1970)
            } catch {
                throw error
            }
        } catch {
            throw error
        }
    }
}

internal extension JSONEncoder.DateEncodingStrategy {
    static let nvmDateStrategySince1970 = custom {
        var container = $1.singleValueContainer()
        try container.encode($0.secondsSince1970)
    }
}

internal extension Date {
    var secondsSince1970: Int {
        return Int((self.timeIntervalSince1970).rounded())
    }
}
internal func date(from secondsSince1970: Int) -> Date {
    return Date(timeIntervalSince1970: TimeInterval(secondsSince1970))
}
internal func date(from secondsSince1970: String) -> Date? {
    if let secondsInt = Int(secondsSince1970) {
        return Date(timeIntervalSince1970: TimeInterval(secondsInt))
    } else {
        return nil
    }
}


internal let NVMCompicLettersList = "abcdefghijklmnopqrstuvwxyz"
internal let NVMCompicCapitalLettersList = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
internal let NVMCompicNumbersList = "0123456789"
internal let NVMCompicSymbolsList = "!#$%&()*+,-./:;<=>?@[]^_`{}"
internal let NVMCompicCharactersList = "§çàæãåáäâāéëêèęėēúüûùūíïìîįīóöôòõœøō£Œ|∏Óı∫√¢⁄›Ω∑∆·ﬂÎÍËÆÅÊ‚™Ÿªï„”’å»ÛÁØ°¤¥©®ß˥˦˧˨˩ͶͷϴŸ|~"

internal func randomString(length: Int, letters: Bool, capitalLetters: Bool, numbers: Bool, symbols: Bool, characters: Bool) -> String {
    var stringCharacters = ""
    
    
    if letters {
        stringCharacters = stringCharacters + NVMCompicLettersList
    }
    if capitalLetters {
        stringCharacters = stringCharacters + NVMCompicCapitalLettersList
    }
    if numbers {
        stringCharacters = stringCharacters + NVMCompicNumbersList
    }
    if symbols {
        stringCharacters = stringCharacters + NVMCompicSymbolsList
    }
    if characters {
        stringCharacters = stringCharacters + NVMCompicCharactersList
    }
    
    if stringCharacters == "" {stringCharacters = stringCharacters + NVMCompicNumbersList}
    
    return String((0..<length).map{ _ in stringCharacters.randomElement()! })
}

internal extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}

internal func daysBetweenDates(_ oldDate: Date, _ newDate: Date) -> Int {
    let diffComponents = Calendar.current.dateComponents([.day], from: oldDate, to: newDate)
    if let days = diffComponents.day {
        return days
    } else {
        return 0
    }
}

extension String {
    internal var toFileName: String {
        return (self.toBase64().replacingOccurrences(of: "[^A-Za-z0-9]+", with: "", options: [.regularExpression]).prefix(200)) + ".compic"
    }
}
