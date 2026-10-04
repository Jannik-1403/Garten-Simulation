import Foundation
struct Test: Codable { var d: Date }
let t = Test(d: Date(timeIntervalSince1970: 1000000))
let data = try! JSONEncoder().encode(t)
print(String(data: data, encoding: .utf8)!)
