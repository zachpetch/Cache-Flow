//
//  ContentView.swift
//  Cache Flow
//
//  Created by Zach Petch on 2024-02-13.
//

import SwiftUI
import Security
import Foundation

/*
 TODO: Make it continue to attempt generating larger and larger files until it errors (or perhaps until it errors OR hits some pre-determined max, whichever comes first), in order to clear the largest amount of cache possible.
 */

struct ContentView: View {
    @State private var isLoading = false
    @State private var greatBigOnes = 10
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("Step One")
                Picker("File Size", selection: $greatBigOnes) {
                    ForEach(Array(stride(from: 5, to: 65, by: 5)), id: \.self) { number in
                        Text("\(number)GB").tag(number)
                    }
                }
                Text("How many gigabytes of space do you need?")
                Spacer()
                Text("Step Two")
                Button("Generate Cache Flow") {
                    isLoading = true
                    DispatchQueue.global(qos: .userInitiated).async {
                        generateCacheFile()
                    }
                }
                Text("First click that ^")
                Spacer()
                Text("Step Two")
                Button("Clear Cache") {
                    deleteCacheFile()
                }
                Text("Then click that ^")
                Spacer()
            }
            .opacity(isLoading ? 0 : 1)
            .padding()
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.blue)
                .scaleEffect(2)
                .opacity(isLoading ? 1 : 0)
        }
    }
    
    func generateCacheFile() {
        let dataSize = greatBigOnes * 1024 * 1024 * 1024 // 10 GB
        print("Generating a \(greatBigOnes)GB file.")
        var dataFile = Data(count: dataSize)
        let status = dataFile.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, dataSize, $0.baseAddress!)
        }
        
        // Check that random data was generated successfully
        if status == errSecSuccess {
            let fm = FileManager.default
            let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = "major_cache_flow.dat"
            let fileURL = documentsURL.appendingPathComponent(fileName)
            do {
                try dataFile.write(to: fileURL)
                print("File saved at \(fileURL)")
                isLoading = false
            } catch {
                print("Error writing file: \(error)")
            }
        } else {
            print("Error generating cache flow: \(status)")
        }
        
        DispatchQueue.main.async {
            isLoading = false
        }
    }
    
    func deleteCacheFile() {
        let fm = FileManager.default
        let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = "major_cache_flow.dat"
        let fileURL = documentsURL.appendingPathComponent(fileName)
        if fm.fileExists(atPath: fileURL.path) {
            do {
                try fm.removeItem(atPath: fileURL.path)
                print("File deleted at \(fileURL)")
            } catch {
                print("Error deleting file at \(fileURL)")
            }
        } else {
            print("File not found at \(fileURL)")
        }
    }
}

#Preview {
    ContentView()
}
