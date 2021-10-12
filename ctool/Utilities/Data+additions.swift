//
//	Data+load.swift
//
// 	Created by Cero on 2021-10-05
//	Copyright © Cero, all rights reserved
//
	

import Foundation

extension Data {
    func load<T>(byteOffset: Int = 0) -> T {
        let size: Int = MemoryLayout<T>.size
        let data: Data = self[byteOffset..<byteOffset + size]
        let initType: T = data.withUnsafeBytes { pointer in
            return pointer.load(as: T.self)
        }
        return initType
    }
    
    func dataWithOffset(_ offset: Int,_ size: Int = 0) -> Data? {
        guard
            offset < self.count,
            offset > 0
        else {
            return nil
        }
        
        let range: Range = offset..<(size != 0 ? size : count)
        let subdata: Data = self.subdata(in: range)
        return subdata
    }
}
