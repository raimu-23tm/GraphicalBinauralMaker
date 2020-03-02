import Foundation
import Metal
import MetalKit


class Renderer : NSObject {
    // local datas
    private var vertices: [Vertex]!
    private var vertexBuffer: MTLBuffer!
    private var indices: [UInt16]!
    private var indexBuffer: MTLBuffer!
    // for MetalAPI
    private var mtlDevice: MTLDevice!
    private var mtkview: MTKView!
    
    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    
    private var uniforms: Uniforms!
    private var preferredFramesTime: Float!
    
    init(metalKitView mtkView: MTKView) {
        super.init()
        self.mtkview = mtkView
        
        // MTKViewのセットアップ
        guard let device = mtkView.device else {
            print("mtkview doesn't have mtlDevice")
            return
        }
        self.mtlDevice = device
        
        // MTLCommandQueueを初期化
        commandQueue = device.makeCommandQueue()
        
        // local datasの初期値設定
        vertices = [Vertex]()
        indices = [UInt16]()
        uniforms = Uniforms(time: Float(0.0), aspectRatio: Float(0.0), touch: float2())
        uniforms.aspectRatio = Float(mtkView.frame.size.width / mtkView.frame.size.height)
        preferredFramesTime = 1.0 / Float(mtkView.preferredFramesPerSecond)

    }
    
    //バッファー設定
    private func buildBuffer() {
        vertexBuffer = mtlDevice.makeBuffer(bytes: vertices, length: vertices.count*MemoryLayout<Vertex>.stride, options: [])
        indexBuffer = mtlDevice.makeBuffer(bytes: indices, length: indices.count*MemoryLayout<UInt16>.stride, options: [])
    }
    
    //パイプライン設定
    private func buildPipeline() {
        let library = mtlDevice.makeDefaultLibrary()
        //パイプラインでシェーダ関数を使う
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        
        //ピクセルフォーマットを指定
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            //レンダリングパイプライン作成
            try pipelineState = mtlDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error: ", error)
        }
    }
    
}

extension Renderer {
    
    //start処理
    public func start () {
        //バッファー設定
        buildBuffer()
        
        //パイプライン設定
        buildPipeline()
        
        mtkview.delegate = self
    }
    
    public func setVertices(_ vertices: [float3]) {
        self.vertices += vertices.map({ (pos) -> Vertex in
            return Vertex(position: pos)
        })
    }
    public func setIndices(_ indices: [Int]) {
        self.indices += indices.map({ (n) -> UInt16 in
            return UInt16(n)
        })
    }
    
    public func applyTouch(touch: float2) {
        uniforms.touch = touch
    }
}


extension Renderer: MTKViewDelegate{
    
    //dwaw処理
    public func draw(in view: MTKView) {
        
        //Time変数を進める
        uniforms.time += preferredFramesTime
        
        // ドローアブルを取得
        guard let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor else {
                print("cannot get drawable or renderPassDescriptor")
                return
        }
        
        // コマンドバッファを作成
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        // エンコーダ生成
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        // エンコーダにパイプラインを設定
        commandEncoder?.setRenderPipelineState(pipelineState)
        
        // vertexBufferを設定
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        
        // 「プリミティブ」(点・直線・三角形といった、頂点からなる基本的な図形)
        //  の描画を行うためのメソッドを呼ぶ
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        
        // エンコード完了
        commandEncoder?.endEncoding()
        
        // 表示するドローアブルを登録
        commandBuffer?.present(drawable)
        
        // コマンドバッファをコミット
        commandBuffer?.commit()
        
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
}

struct Vertex {
    var position: float3
}

struct Uniforms {
    var time: Float
    var aspectRatio: Float
    var touch: float2
}
