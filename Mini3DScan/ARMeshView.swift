import ARKit
import SceneKit
import SwiftUI

struct ARMeshView: UIViewRepresentable {
    let model: ScanModel

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let view = ARSCNView(frame: .zero)
        view.scene = SCNScene()
        view.delegate = context.coordinator
        view.session.delegate = context.coordinator
        view.automaticallyUpdatesLighting = true
        view.rendersContinuously = true

        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .mesh
        view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        return view
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
        uiView.session.pause()
    }

    final class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        let model: ScanModel

        init(model: ScanModel) {
            self.model = model
        }

        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            guard let meshAnchor = anchor as? ARMeshAnchor else { return nil }
            guard let geometry = MeshGeometry.make(from: meshAnchor) else { return SCNNode() }
            return SCNNode(geometry: geometry)
        }

        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let meshAnchor = anchor as? ARMeshAnchor else { return }
            node.geometry = MeshGeometry.make(from: meshAnchor)
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            publish(session)
        }

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            publish(session)
        }

        func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
            publish(session)
        }

        func session(_ session: ARSession, didFailWithError error: Error) {
            model.noteSessionFailure()
        }

        private func publish(_ session: ARSession) {
            let meshes = session.currentFrame?.anchors.compactMap { $0 as? ARMeshAnchor } ?? []
            model.replaceAnchors(meshes)
        }
    }
}

enum MeshGeometry {
    static func make(from meshAnchor: ARMeshAnchor) -> SCNGeometry? {
        let vertices = meshAnchor.geometry.vertices
        let faces = meshAnchor.geometry.faces
        guard vertices.count > 0, faces.count > 0, faces.bytesPerIndex > 0 else { return nil }

        let vertexByteCount = vertices.stride * vertices.count
        let vertexStart = vertices.buffer.contents().advanced(by: vertices.offset)
        let vertexData = Data(bytes: vertexStart, count: vertexByteCount)

        let source = SCNGeometrySource(
            data: vertexData,
            semantic: .vertex,
            vectorCount: vertices.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: vertices.stride
        )

        let indexByteCount = faces.count * faces.indexCountPerPrimitive * faces.bytesPerIndex
        let indexData = Data(bytes: faces.buffer.contents(), count: indexByteCount)
        let element = SCNGeometryElement(
            data: indexData,
            primitiveType: .triangles,
            primitiveCount: faces.count,
            bytesPerIndex: faces.bytesPerIndex
        )

        let geometry = SCNGeometry(sources: [source], elements: [element])
        let material = SCNMaterial()
        material.fillMode = .lines
        material.diffuse.contents = UIColor.white
        material.isDoubleSided = true
        material.lightingModel = .constant
        geometry.materials = [material]
        return geometry
    }
}
