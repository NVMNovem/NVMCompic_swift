//
//  File.swift
//  
//
//  Created by Damian Van de Kauter on 15/03/2022.
//

import Foundation

extension String {
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

public extension JSONDecoder.DateDecodingStrategy {
    static let nvmCompicDateStrategyISO = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)
        if let date = ISO8601DateFormatter().date(from: string) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
    }
    static let nvmCompicISODateStrategy = custom {
        do {
            let container = try $0.singleValueContainer()
            do {
                let isoDate = try container.decode(String.self)
                if let dateISO = ISO8601DateFormatter().date(from: isoDate) {
                    return dateISO
                } else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(isoDate)")
                }
            } catch {
                throw error
            }
        } catch {
            throw error
        }
    }
}
