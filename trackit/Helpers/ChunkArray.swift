//
//  ChunkArray.swift
//  trackit
//
//  Created by Samuel Valencia on 5/4/25.
//

func chunkArray<T> (array: [T], chunkSize: Int) -> [[T]] {
    var results: [[T]] = []
    var currentIndex = 0
    
    while currentIndex < array.count {
        let remaining = array.count - currentIndex
        let batchSize = min(chunkSize, remaining)
        let chunk = Array(array[currentIndex..<currentIndex + batchSize])
        results.append(chunk)
        currentIndex += batchSize
    }
    
    return results
}
