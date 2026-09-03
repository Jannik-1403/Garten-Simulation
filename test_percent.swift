import Foundation

let val = 50
print("Int:", val.formatted(.percent))
print("Double:", (Double(val) / 100).formatted(.percent))
