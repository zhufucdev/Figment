import SwiftUI

struct ZoomableScrollView<Content: View>: NSViewRepresentable {
    private var content: Content
    @Binding private var scale: CGFloat
    let maxScale: CGFloat
    let minScale: CGFloat
    let enableScaling: Bool

    init(scale: Binding<CGFloat>, enableZooming: Bool = true, maxScale: CGFloat = 4.0, minScale: CGFloat = 1.0, @ViewBuilder content: () -> Content) {
        _scale = scale
        self.maxScale = maxScale
        self.minScale = minScale
        enableScaling = enableZooming
        self.content = content()
    }

    func makeNSView(context: Context) -> NSScrollView {
        // set up the NSScrollView
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.allowsMagnification = enableScaling
        scrollView.maxMagnification = maxScale
        scrollView.minMagnification = minScale

        // Create a NSHostingController to hold our SwiftUI content
        let hostedView = context.coordinator.viewForZooming
        scrollView.documentView = hostedView
        scrollView.addObserver(context.coordinator, forKeyPath: "magnification", options: [.new], context: nil)

        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: NSHostingController(rootView: content), scale: $scale)
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = content
        let hostedView = context.coordinator.viewForZooming
        var width = hostedView.fittingSize.width
        var height = hostedView.fittingSize.height
        if width < nsView.bounds.width {
            width = nsView.bounds.width
        }
        if height < nsView.bounds.height {
            height = nsView.bounds.height
        }
        hostedView.setFrameSize(NSSize(width: width, height: height))

        nsView.allowsMagnification = enableScaling
        nsView.magnification = scale
        nsView.maxMagnification = maxScale
    }

    class Coordinator: NSObject {
        var hostingController: NSHostingController<Content>
        @Binding var scale: CGFloat

        init(hostingController: NSHostingController<Content>, scale: Binding<CGFloat>) {
            self.hostingController = hostingController
            _scale = scale
        }

        var viewForZooming: NSView {
            return hostingController.view
        }

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "magnification" {
                scale = change![.newKey]! as! CGFloat
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }
    }
}

#Preview {
    @Previewable
    @State
    var scale: CGFloat = 1
    @Previewable
    @State
    var enabled = true

    ZoomableScrollView(scale: $scale, enableZooming: enabled) {
        ZStack {
            Rectangle()
                .foregroundStyle(.blue)
                .border(.red)
                .frame(width: 200, height: 900)
            Text("\(scale * 100)%")
        }
    }
    HStack {
        Button("Reset zoom") {
            scale = 1
        }
        Toggle("Allow scaling", isOn: $enabled)
    }
}
