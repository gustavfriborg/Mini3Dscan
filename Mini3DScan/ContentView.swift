import ARKit
import SwiftUI

struct ContentView: View {
    @StateObject private var model = ScanModel()
    @State private var isSaving = false
    @State private var alertMessage: String?
    @State private var shareItem: ShareItem?

    private var hasLiDAR: Bool {
        ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    }

    var body: some View {
        ZStack {
            if hasLiDAR {
                ARMeshView(model: model)
                    .ignoresSafeArea()
            } else {
                missingLiDAR
            }

            VStack {
                Spacer()
                controlBar
            }
        }
        .alert("Kan ikke gemme", isPresented: alertIsPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(url: item.url)
        }
    }

    private var alertIsPresented: Binding<Bool> {
        Binding(
            get: { alertMessage != nil },
            set: { isPresented in
                if !isPresented {
                    alertMessage = nil
                }
            }
        )
    }

    private var missingLiDAR: some View {
        VStack(spacing: 16) {
            Image(systemName: "viewfinder")
                .font(.system(size: 56))
            Text("Denne enhed har ikke LiDAR")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
            Text("Mini3DScan skal bruge en iPhone Pro eller iPad Pro med LiDAR-scanner for at bygge en 3D-model af rummet.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    private var controlBar: some View {
        VStack(spacing: 12) {
            Text(statusText)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Button(action: gemScanning) {
                Text(isSaving ? "Gemmer…" : "Gem scanning")
                    .font(.title2.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(!hasLiDAR || isSaving)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    private var statusText: String {
        if !hasLiDAR {
            return "LiDAR mangler, så der er intet at gemme."
        }
        if model.sessionFailed {
            return "Kamerasessionen kunne ikke starte. Tjek at Mini3DScan må bruge kameraet."
        }
        if model.meshPartCount == 0 {
            return "Bevæg telefonen langsomt rundt i rummet, indtil overfladerne tegnes."
        }
        return "Overfladestykker: \(model.meshPartCount). Tryk på knappen for at gemme en OBJ-fil."
    }

    private func gemScanning() {
        let anchors = model.anchors
        guard !anchors.isEmpty else {
            alertMessage = "Intet mesh endnu. Bevæg telefonen rundt i rummet, indtil overfladerne tegnes, og prøv igen."
            return
        }

        isSaving = true
        do {
            let url = try MeshOBJExporter.exportToDocuments(anchors: anchors)
            isSaving = false
            shareItem = ShareItem(url: url)
        } catch {
            isSaving = false
            alertMessage = "Scanningen kunne ikke gemmes. Prøv igen."
        }
    }
}
