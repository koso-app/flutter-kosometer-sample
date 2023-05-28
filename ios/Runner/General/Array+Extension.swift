import Foundation

extension Array {
    func toInt32() -> Int32 where Element == UInt8 {
        return withUnsafeBytes {
            $0.load(as: Int32.self).bigEndian
        }
    }

    func toUInt32() -> UInt32 where Element == UInt8 {
        return withUnsafeBytes {
            $0.load(as: UInt32.self).bigEndian
        }
    }

    func toInt16() -> Int16 where Element == UInt8 {
        return withUnsafeBytes {
            $0.load(as: Int16.self).bigEndian
        }
    }

    func toUInt16() -> UInt16 where Element == UInt8 {
        return withUnsafeBytes {
            $0.load(as: UInt16.self).bigEndian
        }
    }

    func getFirst(_ value: Int) -> [Element] {
        if value > count {
            return self
        } else {
            return Array(self[0 ..< value])
        }
    }
}

func byteArrayBig<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
    withUnsafeBytes(of: value.bigEndian, Array.init)
}

func byteArrayLittle<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
    withUnsafeBytes(of: value.littleEndian, Array.init)
}
