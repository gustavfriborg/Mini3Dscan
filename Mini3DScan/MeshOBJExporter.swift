import ARKit
import Foundation
import simd

enum MeshOBJExporter {
    enum ExportError: Error {
        case emptyMesh
    }

    static func exportToDocuments(anchors: [ARMeshAnchor]) throws -> URL {
        let documents = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let url = documents.appendingPathComponent("Mini3DScan-\(formatter.string(from: Date())).obj")
        try write(anchors: anchors, to: url)
        return url
    }

    /// Writes every mesh anchor into one OBJ file. Positions are transformed into
    /// world space and stay in metres, which is ARKit's unit.
    static func write(anchors: [ARMeshAnchor], to url: URL) throws {
        FileManager.default.createFile(atPath: url.path, contents: nil)
        let handle = try FileHandle(forWritingTo: url)
        defer { try? handle.close() }

        var buffer = Data()
        buffer.reserveCapacity(1 << 20)
        let posix = Locale(identifier: "en_US_POSIX")

        func append(_ string: String) throws {
            buffer.append(contentsOf: string.utf8)
            if buffer.count >= (1 << 20) {
                try handle.write(contentsOf: buffer)
                buffer.removeAll(keepingCapacity: true)
            }
        }

        try append("# Mini3DScan\n# enhed: meter\n")
        var vertexOffset = 0
        var wroteFace = false

        for anchor in anchors {
            let vertices = anchor.geometry.vertices
            let faces = anchor.geometry.faces
            guard vertices.count > 0, faces.count > 0 else { continue }

            let transform = anchor.transform
            let vertexBase = vertices.buffer.contents()
            for index in 0..<vertices.count {
                let raw = vertexBase.advanced(by: vertices.offset + vertices.stride * index)
                let local = SIMD4<Float>(
                    raw.load(fromByteOffset: 0, as: Float.self),
                    raw.load(fromByteOffset: MemoryLayout<Float>.size, as: Float.self),
                    raw.load(fromByteOffset: MemoryLayout<Float>.size * 2, as: Float.self),
                    1
                )
                let world = transform * local
                try append(
                    String(
                        format: "v %.5f %.5f %.5f\n",
                        locale: posix,
                        world.x,
                        world.y,
                        world.z
                    )
                )
            }

            let faceBase = faces.buffer.contents()
            let corners = faces.indexCountPerPrimitive
            let bytesPerIndex = faces.bytesPerIndex
            for face in 0..<faces.count {
                var indices: [String] = []
                indices.reserveCapacity(corners)
                for corner in 0..<corners {
                    let byteOffset = (face * corners + corner) * bytesPerIndex
                    let localIndex: Int
                    switch bytesPerIndex {
                    case MemoryLayout<UInt16>.size:
                        localIndex = Int(faceBase.load(fromByteOffset: byteOffset, as: UInt16.self))
                    case MemoryLayout<UInt32>.size:
                        localIndex = Int(faceBase.load(fromByteOffset: byteOffset, as: UInt32.self))
                    case MemoryLayout<UInt64>.size:
                        localIndex = Int(faceBase.load(fromByteOffset: byteOffset, as: UInt64.self))
                    default:
                        localIndex = -1
                    }
                    if localIndex >= 0 {
                        // OBJ indices are 1-based and continue across anchors.
                        indices.append(String(localIndex + 1 + vertexOffset))
                    }
                }
                if indices.count >= 3 {
                    try append("f \(indices.joined(separator: " "))\n")
                    wroteFace = true
                }
            }

            vertexOffset += vertices.count
        }

        if !wroteFace {
            try? FileManager.default.removeItem(at: url)
            throw ExportError.emptyMesh
        }

        if !buffer.isEmpty {
            try handle.write(contentsOf: buffer)
        }
    }
}
