import Foundation
import CSQLite

/// Swift WASM module that queries SQLite directly
/// JavaScript loads database file and passes bytes to Swift
/// Swift uses native SQLite to query and return JSON

// Import console logging from JavaScript
@_extern(wasm, module: "env", name: "consoleLog")
@_extern(c)
func consoleLog(_ messagePtr: UnsafeRawPointer, _ messageLen: Int32)

// Global database handle and memory
private var db: OpaquePointer? = nil
private var dataChunks: [Int: OpaquePointer] = [:] // chunk_num -> database handle
private var dbMemory: UnsafeMutableRawBufferPointer? = nil // Store database memory globally
private var jsonOutputBuffer: [UInt8] = [] // Swift-managed output buffer separate from WASM memory

private func log(_ message: String) {
    let utf8 = Array(message.utf8)
    utf8.withUnsafeBufferPointer { ptr in
        consoleLog(ptr.baseAddress!, Int32(utf8.count))
    }
}

// Initialize Swift WASM and load SQLite database from memory
@_expose(wasm, "swiftInit")
@_cdecl("swiftInit")
public func swiftInit(_ dbPtr: UnsafeRawPointer, _ dbSize: Int32) -> Int32 {
    log("🚀 Swift WASM initializing with database (\(dbSize) bytes)...")
    
    // Open in-memory database WITHOUT deserialize
    var tempDb: OpaquePointer? = nil
    var rc = sqlite3_open(":memory:", &tempDb)
    
    guard rc == SQLITE_OK, let openedDb = tempDb else {
        if let error = sqlite3_errmsg(tempDb) {
            log("❌ Failed to open database: \(String(cString: error))")
        }
        sqlite3_close(tempDb)
        return 0
    }
    
    // Store the memory pointer globally
    let dbBytes = UnsafeRawBufferPointer(start: dbPtr, count: Int(dbSize))
    let mutableCopy = UnsafeMutableRawBufferPointer.allocate(byteCount: Int(dbSize), alignment: 1)
    mutableCopy.copyBytes(from: dbBytes)
    dbMemory = mutableCopy
    
    // Use FREEONCLOSE flag - let SQLite own the memory completely
    rc = sqlite3_deserialize(
        openedDb,
        "main",
        mutableCopy.baseAddress?.assumingMemoryBound(to: UInt8.self),
        sqlite3_int64(dbSize),
        sqlite3_int64(dbSize),
        UInt32(SQLITE_DESERIALIZE_FREEONCLOSE)  // Let SQLite free it
    )
    
    if rc != SQLITE_OK {
        if let error = sqlite3_errmsg(openedDb) {
            log("❌ Failed to deserialize database: \(String(cString: error))")
        }
        sqlite3_close(openedDb)
        return 0
    }
    
    db = openedDb
    log("✅ SQLite database loaded successfully")
    
    // Verify database has data
    var countStmt: OpaquePointer? = nil
    let testSQL = "SELECT COUNT(*) FROM package_index"
    rc = sqlite3_prepare_v2(openedDb, testSQL, -1, &countStmt, nil)
    
    if rc != SQLITE_OK {
        if let error = sqlite3_errmsg(openedDb) {
            log("❌ Failed to query package_index: \(String(cString: error))")
        }
        log("❌ Database might be corrupted or empty")
        sqlite3_close(openedDb)
        db = nil
        return 0
    }
    
    if let stmt = countStmt, sqlite3_step(stmt) == SQLITE_ROW {
        let count = sqlite3_column_int(stmt, 0)
        log("✅ Database verified: \(count) packages in index")
    }
    sqlite3_finalize(countStmt)
    
    return 1
}

// Attach a data chunk database
@_expose(wasm, "swiftAttachChunk")
@_cdecl("swiftAttachChunk")
public func swiftAttachChunk(_ chunkNum: Int32, _ dbPtr: UnsafeRawPointer, _ dbSize: Int32) -> Int32 {
    log("📎 Attaching data chunk \(chunkNum) (\(dbSize) bytes)...")
    
    guard db != nil else {
        log("❌ Main database not initialized")
        return 0
    }
    
    // Deserialize chunk into memory first
    let dbBytes = UnsafeRawBufferPointer(start: dbPtr, count: Int(dbSize))
    let mutableCopy = UnsafeMutableRawBufferPointer.allocate(byteCount: Int(dbSize), alignment: 1)
    mutableCopy.copyBytes(from: dbBytes)
    
    // Open a separate in-memory database for this chunk
    var chunkDb: OpaquePointer? = nil
    var rc = sqlite3_open(":memory:", &chunkDb)
    
    guard rc == SQLITE_OK, let openedChunkDb = chunkDb else {
        log("❌ Failed to open chunk database")
        return 0
    }
    
    // Deserialize the chunk - use FREEONCLOSE so SQLite owns the memory
    rc = sqlite3_deserialize(
        openedChunkDb,
        "main",
        mutableCopy.baseAddress?.assumingMemoryBound(to: UInt8.self),
        sqlite3_int64(dbSize),
        sqlite3_int64(dbSize),
        UInt32(SQLITE_DESERIALIZE_FREEONCLOSE)  // Let SQLite manage memory
    )
    
    if rc != SQLITE_OK {
        log("❌ Failed to deserialize chunk")
        sqlite3_close(openedChunkDb)
        return 0
    }
    
    // Store the chunk database handle for queries
    dataChunks[Int(chunkNum)] = openedChunkDb
    log("✅ Data chunk \(chunkNum) attached successfully")
    
    return 1
}

// Search packages using native SQLite queries
@_expose(wasm, "swiftSearch")
@_cdecl("swiftSearch")
public func swiftSearch(_ queryPtr: UnsafeRawPointer, _ queryLen: Int32, _ outputPtr: UnsafeMutablePointer<UInt8>, _ outputLen: Int32) -> Int32 {
    log("🔍 swiftSearch called with queryLen: \(queryLen)")
    
    guard db != nil else {
        log("❌ Database not initialized")
        return 0
    }
    
    // Read query string from memory
    let queryBytes = UnsafeBufferPointer(start: queryPtr.assumingMemoryBound(to: UInt8.self), count: Int(queryLen))
    
    guard let query = String(bytes: queryBytes, encoding: .utf8), !query.isEmpty else {
        log("❌ Invalid query string")
        return 0
    }
    
    log("🔍 Searching for: \(query)")
    
    // Execute SQL query to search package index
    let escapedQuery = query.replacingOccurrences(of: "'", with: "''")
    log("📝 Escaped query: \(escapedQuery)")
    
    // Build SQL query - use single allocation to avoid fragmentation
    let indexSQL = String(format: "SELECT name, hash_id, chunk_file FROM package_index WHERE name LIKE '%%%@%%' ORDER BY CASE WHEN name = '%@' THEN 0 WHEN name LIKE '%@%%' THEN 1 ELSE 2 END, LENGTH(name), name LIMIT 1000", escapedQuery, escapedQuery, escapedQuery)
    
    log("🔍 SQL query prepared, length: \(indexSQL.utf8.count)")
    
    var indexStmt: OpaquePointer? = nil
    // Use withCString to ensure stable C string pointer
    let prepareRc = indexSQL.withCString { sqlPtr in
        sqlite3_prepare_v2(db, sqlPtr, -1, &indexStmt, nil)
    }
    
    guard prepareRc == SQLITE_OK, let statement = indexStmt else {
        log("❌ SQL error code: \(prepareRc) (1=SQLITE_ERROR)")
        if let error = sqlite3_errmsg(db) {
            let errMsg = String(cString: error)
            log("❌ Error message length: \(errMsg.count)")
            log("❌ Error message first 200 chars: \(String(errMsg.prefix(200)))")
        }
        if let currentDb = db {
            let extendedCode = sqlite3_extended_errcode(currentDb)
            log("❌ Extended error code: \(extendedCode)")
        }
        return 0
    }
    
    defer { sqlite3_finalize(statement) }
    
    // Collect index results
    log("📋 Collecting index results...")
    var indexResults: [(name: String, hashId: Int64, chunkFile: Int)] = []
    while sqlite3_step(statement) == SQLITE_ROW {
        guard let nameCStr = sqlite3_column_text(statement, 0) else { continue }
        let name = String(cString: nameCStr)
        let hashId = sqlite3_column_int64(statement, 1)
        let chunkFile = Int(sqlite3_column_int(statement, 2))
        indexResults.append((name, hashId, chunkFile))
    }
    
    log("📊 Found \(indexResults.count) packages in index")
    
    guard !indexResults.isEmpty else { return 0 }
    
    // Group results by chunk file
    var resultsByChunk: [Int: [(name: String, hashId: Int64)]] = [:]
    for indexRow in indexResults {
        if resultsByChunk[indexRow.chunkFile] == nil {
            resultsByChunk[indexRow.chunkFile] = []
        }
        resultsByChunk[indexRow.chunkFile]?.append((indexRow.name, indexRow.hashId))
    }
    
    log("📊 Need to query \(resultsByChunk.count) data chunks")
    
    // Query each chunk and collect results
    var allData: [Int64: (downloads: Int, androidSupport: Int, iosSupport: Int, source: Int, category: Int, androidVersion: String?, iosVersion: String?, latestVersion: String?)] = [:]
    
    for (chunkNum, packages) in resultsByChunk {
        guard let chunkDb = dataChunks[chunkNum] else {
            log("⚠️ Chunk \(chunkNum) not loaded, skipping")
            continue
        }
        
        let hashIds = packages.map { String($0.hashId) }.joined(separator: ",")
        let dataSQL = """
            SELECT hash_id, downloads, android_support, ios_support, source, category,
                   android_version, ios_version, latest_version
            FROM package_data
            WHERE hash_id IN (\(hashIds))
        """
        
        var dataStmt: OpaquePointer? = nil
        let rc = sqlite3_prepare_v2(chunkDb, dataSQL, -1, &dataStmt, nil)
        
        guard rc == SQLITE_OK, let stmt = dataStmt else {
            if let error = sqlite3_errmsg(chunkDb) {
                log("❌ Failed to query chunk \(chunkNum): \(String(cString: error))")
            }
            continue
        }
        
        defer { sqlite3_finalize(stmt) }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let hashId = sqlite3_column_int64(stmt, 0)
            let downloads = Int(sqlite3_column_int(stmt, 1))
            let androidSupport = Int(sqlite3_column_int(stmt, 2))
            let iosSupport = Int(sqlite3_column_int(stmt, 3))
            let source = Int(sqlite3_column_int(stmt, 4))
            let category = Int(sqlite3_column_int(stmt, 5))
            
            let androidVersion = sqlite3_column_text(stmt, 6).map { String(cString: $0) }
            let iosVersion = sqlite3_column_text(stmt, 7).map { String(cString: $0) }
            let latestVersion = sqlite3_column_text(stmt, 8).map { String(cString: $0) }
            
            allData[hashId] = (downloads, androidSupport, iosSupport, source, category, androidVersion, iosVersion, latestVersion)
        }
    }
    
    log("📊 Collected data for \(allData.count) packages")
    
    // Build results with actual data
    log("🔨 Building JSON results...")
    var jsonResults: [[String: Any]] = []
    for indexRow in indexResults {
        guard let data = allData[indexRow.hashId] else {
            // Package not found in data chunks
            let result: [String: Any] = [
                "name": indexRow.name,
                "hash_id": String(indexRow.hashId),
                "chunk_file": indexRow.chunkFile,
                "ios": "unknown",
                "android": "unknown",
                "category": "unknown",
                "source": "unknown",
                "downloads": 0
            ]
            jsonResults.append(result)
            continue
        }
        
        let iosSupportStr = PlatformSupportCategory(rawValue: data.iosSupport)?.jsValue ?? "not_available"
        let androidSupportStr = PlatformSupportCategory(rawValue: data.androidSupport)?.jsValue ?? "not_available"
        let sourceObj = PackageSourceIndex(rawValue: data.source) ?? .pypi
        let categoryObj = PackageCategoryType(rawValue: data.category) ?? .unprocessed
        
        var result: [String: Any] = [
            "name": indexRow.name,
            "hash_id": String(indexRow.hashId),
            "downloads": data.downloads,
            "ios": iosSupportStr,
            "android": androidSupportStr,
            "category": categoryObj.categoryDisplayName(source: sourceObj),
            "source": sourceObj.displayName
        ]
        
        if let ver = data.iosVersion { result["ios_version"] = ver }
        if let ver = data.androidVersion { result["android_version"] = ver }
        if let ver = data.latestVersion { result["latest_version"] = ver }
        
        jsonResults.append(result)
    }
    
    log("📊 Built \(jsonResults.count) JSON results")
    
    // Encode to JSON
    log("🔧 Encoding JSON...")
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: jsonResults)
        
        // Store in Swift-managed buffer first (completely separate from WASM linear memory)
        jsonOutputBuffer = Array(jsonData)
        
        // Copy to WASM output pointer
        let bytesToWrite = min(jsonOutputBuffer.count, Int(outputLen))
        for i in 0..<bytesToWrite {
            outputPtr[i] = jsonOutputBuffer[i]
        }
        
        log("✅ Returning \(jsonResults.count) results (\(bytesToWrite) bytes)")
        return Int32(bytesToWrite)
    } catch {
        log("❌ Failed to encode JSON: \(error)")
        return 0
    }
}

// Simple test function
@_expose(wasm, "swiftTest")
@_cdecl("swiftTest")
public func swiftTest() -> Int32 {
    return 42
}

