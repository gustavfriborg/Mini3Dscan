import ARKit
import Combine

final class ScanModel: ObservableObject {
    @Published private(set) var meshPartCount = 0
    @Published private(set) var sessionFailed = false

    private(set) var anchors: [ARMeshAnchor] = []

    func replaceAnchors(_ anchors: [ARMeshAnchor]) {
        DispatchQueue.main.async {
            self.anchors = anchors
            if anchors.count != self.meshPartCount {
                self.meshPartCount = anchors.count
            }
        }
    }

    func noteSessionFailure() {
        DispatchQueue.main.async {
            self.sessionFailed = true
        }
    }
}
