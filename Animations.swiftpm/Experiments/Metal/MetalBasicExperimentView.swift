import SwiftUI
import MetalKit

struct MetalBasicExperimentView: View {
    @State private var intensity = 0.42
    @State private var speed = 0.65
    @State private var showsGrid = true

    var body: some View {
        VStack(spacing: 18) {
            TimelineView(.animation) { timeline in
                MetalView()
            }
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: .rect(cornerRadius: 18))
        }
    }
}

private struct MetalView: UIViewRepresentable {
    func makeCoordinator() -> Renderer {
        Renderer()
    }

    func makeUIView(context: Context) -> MTKView {
        let view = MTKView()
        context.coordinator.configure(view)
        return view
    }

    func updateUIView(_ view: MTKView, context: Context) {
        // сюда позже можно прокидывать SwiftUI-параметры:
        // intensity, speed, color, selectedMesh и т.д.
    }
}

private final class Renderer: NSObject, MTKViewDelegate {
    
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?

    private var mesh: MTKMesh?
    private var pipelineState: MTLRenderPipelineState?

    func configure(_ view: MTKView) {
//        // 1. create device
//        guard let device = MTLCreateSystemDefaultDevice() else { fatalError("GPU is not supported") }
//        // 2. assign view.device
//        
//        // 3. configure pixel format / clear color
//        view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)
//        
//        // 1
//        let allocator = MTKMeshBufferAllocator(device: device)
//        // 2
//        let mdlMesh = MDLMesh(
//          sphereWithExtent: [0.75, 0.75, 0.75],
//          segments: [100, 100],
//          inwardNormals: false,
//          geometryType: .triangles,
//          allocator: allocator)
//        // 3
//        let mesh = try MTKMesh(mesh: mdlMesh, device: device)
//        
//        // 4. create command queue
//        
//        // 5. create model / mesh
//        // 6. create pipeline
//        // 7. set view.delegate = self
    }

    func draw(in view: MTKView) {
        // 1. get currentRenderPassDescriptor
        // 2. get currentDrawable
        // 3. make commandBuffer
        // 4. make renderEncoder
        // 5. set pipeline
        // 6. set vertex buffers / textures / uniforms
        // 7. draw
        // 8. present drawable
        // 9. commit
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}

#Preview {
    MetalBasicExperimentView()
}
