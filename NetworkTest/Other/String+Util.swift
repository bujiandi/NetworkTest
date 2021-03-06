
//#if os(iOS)
//import UIKit
//#elseif os(OSX)
import Foundation
//#endif

extension String {
    
    public static let Empty = ""
    
//    // create a static method to get a swift class for a string name
    public static func swiftClassFromString(_ className: String) -> AnyClass! {
        // get the project name
        if  let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            // generate the full name of your class (take a look into your "YourProject-swift.h" file)
            let classStringName = "_TtC\(appName.utf16.count)\(appName)\(className.length)\(className)"
            // return the class!
            return NSClassFromString(classStringName)
        }
        return nil
    }
    // MARK: - 取类型名
//    public static func typeNameFromClass(_ aClass:AnyClass) -> String {
//        let name = NSStringFromClass(aClass)
//        let demangleName = _stdlib_demangleName(name)
//        return demangleName.components(separatedBy: ".").last!
//    }
    
//    public init(_ items: Any...) {
//        let string = items.map({ "\($0)" }).joinWithSeparator(", ")
//        self.init(string)
//    }

//    static func typeNameFromAny(thing:Any) -> String {
//        let name = _stdlib_getTypeName(thing)
//        let demangleName = _stdlib_demangleName(name)
//        return demangleName.componentsSeparatedByString(".").last!
//    }
    
    // MARK: - 取大小
//    #if os(iOS)
//
//    func boundingRectWithSize(size: CGSize, defaultFont:UIFont = UIFont.systemFont(ofSize: 16), lineBreakMode:NSLineBreakMode = .byWordWrapping) -> CGSize {
//    
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineBreakMode = lineBreakMode
//    
//        return (self as NSString).boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font:defaultFont, .paragraphStyle:paragraphStyle], context: nil).size
//    }
//    
//    #endif
    
    // MARK: - 快捷生成富文本
    public func attributedStringBy(attributes: [NSAttributedStringKey : Any]?) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: attributes)
    }
    
    @inline(__always)
    public func append(_ text:String, `where` condition: @autoclosure () -> Bool = true) -> String {
        return condition() ? self + text : self
    }
    
    // MARK: - 添加路径
    public func stringByAppending(pathComponent:String) -> String {
        return hasSuffix("/") ?
            "\(self)\(pathComponent)" :
            "\(self)/\(pathComponent)"
    }
    
    // MARK: - 取路径末尾文件名
    public var stringByDeletingPathPrefix:String {
        return components(separatedBy: "/").last ?? ""
    }
    // MARK: - 长度
    public var length:Int {
        return distance(from: startIndex, to: endIndex)
    }
    
    // MARK: - 字符串截取
    public func substring(to index:Int) -> String {
        return String(self[...self.index(startIndex, offsetBy: index)])
    }
    public func substring(from index:Int) -> String {
        return String(self[self.index(startIndex, offsetBy: index)...])
    }
    
    public subscript(index:Int) -> Character {
        return self[self.index(startIndex, offsetBy: index)]
    }
    
    public subscript(subRange:Range<Int>, `where` condition: @autoclosure () -> Bool) -> String {
        return condition() ? self[subRange] : self
    }
    public subscript(subRange:CountableClosedRange<Int>, `where` condition: @autoclosure () -> Bool) -> String {
        return condition() ? self[subRange] : self
    }
    public subscript(subRange:PartialRangeThrough<Int>, `where` condition: @autoclosure () -> Bool) -> String {
        return condition() ? self[subRange] : self
    }
    public subscript(subRange:CountablePartialRangeFrom<Int>, `where` condition: @autoclosure () -> Bool) -> String {
        return condition() ? self[subRange] : self
    }
    
    public subscript(subRange:Range<Int>) -> String {
        let start = index(startIndex, offsetBy: subRange.lowerBound)
        let end = index(startIndex, offsetBy: subRange.upperBound)
        return String(self[start..<end])
    }
    public subscript(subRange:CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: subRange.lowerBound)
        let end = index(startIndex, offsetBy: subRange.upperBound)
        return String(self[start...end])
    }
    public subscript(subRange:PartialRangeThrough<Int>) -> String {
        let end = index(startIndex, offsetBy: subRange.upperBound)
        return String(prefix(upTo: end))
    }
    public subscript(subRange:CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: subRange.lowerBound)
        return String(suffix(from: start))
    }
    
    public func substring(with range:Range<Int>) -> Substring {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return self[start..<end]
    }
    
    public func substring(with range:CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return self[start...end]
    }
    
    public func substring(with range:PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: range.upperBound)
        return prefix(upTo: end)
    }
    
    public func substring(with range:CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: range.lowerBound)
        return suffix(from: start)
    }
    
    public func prefix(upTo index:Int) -> Substring {
        let end = self.index(startIndex, offsetBy: index)
        return prefix(upTo: end)
    }
    
    public func suffix(from index:Int) -> Substring {
        let start = self.index(startIndex, offsetBy: index)
        return suffix(from: start)
    }
    
    // MARK: - 字符串修改 RangeReplaceableCollectionType
    public mutating func insert(_ newElement: Character, at i: Int) {
        insert(newElement, at: index(startIndex, offsetBy: i)) //advance(self.startIndex,i))
    }
    
    public mutating func replaceSubrange(_ subRange: Range<Int>, with newValues: String) {
        let start = index(startIndex, offsetBy: subRange.lowerBound)
        let end = index(startIndex, offsetBy: subRange.upperBound)
        replaceSubrange(start..<end, with: newValues)
    }
    public mutating func replaceSubrange(_ subRange: CountableClosedRange<Int>, with newValues: String) {
        let start = index(startIndex, offsetBy: subRange.lowerBound)
        let end = index(startIndex, offsetBy: subRange.upperBound)
        replaceSubrange(start...end, with: newValues)
    }
    public mutating func replaceSubrange(_ subRange: PartialRangeThrough<Int>, with newValues: String) {
        let end = index(startIndex, offsetBy: subRange.upperBound)
        replaceSubrange(...end, with: newValues)
    }
    public mutating func replaceSubrange(_ subRange: CountablePartialRangeFrom<Int>, with newValues: String) {
        let start = index(startIndex, offsetBy: subRange.lowerBound)
        replaceSubrange(start..., with: newValues)
    }
    
    public mutating func remove(at i: Int) -> Character {
        return remove(at: index(startIndex, offsetBy: i)) //advance(self.startIndex,i))
    }
    
    public mutating func removeRange(_ subRange: Range<Int>) {
        let start = index(startIndex, offsetBy: subRange.lowerBound)
        let end = index(startIndex, offsetBy: subRange.upperBound)
        removeSubrange(start..<end)
    }
    public mutating func removeRange(_ subRange: CountableClosedRange<Int>) {
        let start = index(startIndex, offsetBy: subRange.lowerBound)
        let end = index(startIndex, offsetBy: subRange.upperBound)
        removeSubrange(start...end)
    }
    public mutating func removeRange(_ subRange: PartialRangeThrough<Int>) {
        let end = index(startIndex, offsetBy: subRange.upperBound)
        removeSubrange(...end)
    }
    public mutating func removeRange(_ subRange: CountablePartialRangeFrom<Int>) {
        let start = index(startIndex, offsetBy: subRange.lowerBound)
        removeSubrange(start...)
    }
    // MARK: - 字符串拆分
    public func split(byString separator: String) -> [String] {
        return components(separatedBy: separator)
    }
    public func split(byCharacters separators: String) -> [String] {
        return components(separatedBy: CharacterSet(charactersIn: separators))
    }
    
    // MARK: - URL解码/编码
    
    /// 给URL解编码
    public func decodeURL() -> String {
        return removingPercentEncoding ?? self
    }
    
    /// 给URL编码
    public func encodeURL(allowedCharactersIn text: AllowedURLEncodeCharacters = .normal) -> String {
//        let originalString:CFString = self as NSString
//        let charactersToBeEscaped = "!*'();:@&=+$,/?%#." as CFString  //":/?&=;+!@#$()',*"    //转意符号
//        //let charactersToLeaveUnescaped = "[]." as CFStringRef  //保留的符号
//        let result =
//        CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//            originalString,
//            nil,    //charactersToLeaveUnescaped,
//            charactersToBeEscaped,
//            CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)) as NSString
//
//        return result as String
        return addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: text)) ?? self

    }
    
}

public typealias AllowedURLEncodeCharacters = String

extension AllowedURLEncodeCharacters {
    public static let normal:AllowedURLEncodeCharacters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    
    public static let wholeURL:AllowedURLEncodeCharacters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ&@#=_."
}

extension String.UnicodeScalarView {
    public subscript (i: Int) -> UnicodeScalar {
        return self[index(startIndex, offsetBy: i)] //advance(self.startIndex, i)]
    }
}


/// trim 去掉字符串两段的换行与空格
extension String {
    
    public struct TrimMode: OptionSet, ExpressibleByIntegerLiteral {
        public typealias IntegerLiteralType = Int
        
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        public init(integerLiteral value: Int) {
            rawValue = value
        }
        
        public static let both:TrimMode = -1
        public static let prefix = TrimMode(rawValue: 1 << 0)
        public static let suffix = TrimMode(rawValue: 1 << 1)
    }
    
    public func trim(_ mode:TrimMode = .both) -> String {
        var start:Int = 0
        var end:Int = length
        var isBreak = false
        if mode.contains(.prefix) {
            for char:Character in self where !isBreak {
                switch char {
                case " ", "\n", "\r", "\r\n", "\t":   // \r\n 是一个字符  \n\r 是2个字符
                    start += 1
                default:
                    isBreak = true
                }
            }
        }
        if mode.contains(.suffix) {
            isBreak = false
            for char:Character in reversed() where !isBreak {
                switch char {
                case " ", "\n", "\r", "\r\n", "\t":   // \r\n 是一个字符  \n\r 是2个字符
                    end -= 1
                default:
                    isBreak = true
                }
            }
        }
        return self[start..<end]
    }
    
    public func joinIn(_ prefix:String, _ suffix:String) -> String {
        return "\(prefix)\(self)\(suffix)"
    }
    
    public var isNumeric:Bool {
        return matchRegular(try! NSRegularExpression(pattern: "[0-9]+\\.?[0-9]*", options: .caseInsensitive))
    }
    
    public var isInteger:Bool {
        return matchRegular(try! NSRegularExpression(pattern: "[0-9]+", options: .caseInsensitive))
    }
    
    public func matchRegular(_ regular:NSRegularExpression) -> Bool {
        let length = distance(from: startIndex, to: endIndex) //characters.count
        let range = regular.rangeOfFirstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, length))
        return range.location == 0 && range.length == length
    }
    
    public var utf8Data:Data {
        return self.data(using: .utf8) ?? Data()
    }
}

extension Data {
    
    public mutating func append(_ string: String, using chartSet:String.Encoding = .utf8) {
        guard let data = string.data(using: chartSet) else {
            #if DEBUG
            fatalError("error: can't append \"\(string)\" in data using \(chartSet)")
            #else
            return print("error: can't append \"\(string)\" in data using \(chartSet)")
            #endif
        }
        
        self.append(data)
    }
    
}




/*
extension NSURL: StringLiteralConvertible {
public class func convertFromExtendedGraphemeClusterLiteral(value: String) -> Self {
return self(string: value)
}

public class func convertFromStringLiteral(value: String) -> Self {
return self(string: value)
}
}
*/
