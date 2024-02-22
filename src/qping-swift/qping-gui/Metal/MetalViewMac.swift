//
//  ContentView1.swift
//  p3
//
//  Created by Alejandro Garcia on 28/1/23.
//

#if canImport(AppKit)
import SwiftUI
import MetalKit
import AppKit

struct MetalViewMac: NSViewRepresentable  {
    typealias NSViewType = NSView
    @Environment(AppData.self) private var appData
    //@Binding  var path: NavigationPath
    var tipoRender: TipoRenderGPU = TipoRenderGPU.Triangle_1
   
    let mtkView = MTKViewCustom()
    
   // var renderer: Renderer?
    
//    //Constructor
//    init(vistaActiva: VistaActiva)
//    {
//        self.vistaActiva = vistaActiva
//    }
    
    //Crear el coordinador que actualiza la vista
    func makeCoordinator() -> MTKViewDelegate{
            switch(tipoRender)
            {
            case .Mesh_1:
                return RendererMesh1(self,tipoTest: tipoRender)
//            case .Mesh_2:
//                return RendererMesh2(self,tipoTest: tipoTest)
            default:
                return RendererTriangle(self,tipoTest: tipoRender)
            }
    }
    
    //Crear la vista. Solo una vez
    func makeNSView(context: NSViewRepresentableContext <MetalViewMac>) ->  NSView {
        
    
        if let metalDevice = MTLCreateSystemDefaultDevice()
        {
            mtkView.device = metalDevice
        }
        mtkView.delegate = context.coordinator
        mtkView.layer?.isOpaque = false
        
        switch(tipoRender)
        {
       
            
        case TipoRenderGPU.Triangle_3:
            mtkView.preferredFramesPerSecond = 60
            mtkView.enableSetNeedsDisplay = false
            mtkView.isPaused = false
            mtkView.framebufferOnly = false
            mtkView.drawableSize = mtkView.frame.size
            
        case TipoRenderGPU.Cubo_1:
            mtkView.preferredFramesPerSecond = 60
            mtkView.enableSetNeedsDisplay = false
            mtkView.isPaused = false
            mtkView.framebufferOnly = false
            mtkView.drawableSize = mtkView.frame.size
          //  mtkView.depthStencilPixelFormat = MTLPixelFormat(rawValue: 1)
            mtkView.clearDepth = 0.0;
            
        case TipoRenderGPU.Mesh_1:
            //mtkView.preferredFramesPerSecond = 60
            
            //Drawing Behavior mode: Draw notifications
//            mtkView.enableSetNeedsDisplay = true
//            mtkView.isPaused = true
            
            //Drawing Behavior mode: Timed updates
            mtkView.enableSetNeedsDisplay = false
            mtkView.isPaused = false
            
            mtkView.framebufferOnly = false
            mtkView.drawableSize = mtkView.frame.size
            //  mtkView.depthStencilPixelFormat = MTLPixelFormat(rawValue: 1)
            mtkView.clearDepth = 0.0
            mtkView.alphaValue = 1
            mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0)
           
            
           // mtkView.bac
        case TipoRenderGPU.Mesh_2:
            mtkView.preferredFramesPerSecond = 60
            mtkView.enableSetNeedsDisplay = true
            mtkView.isPaused = false
            mtkView.framebufferOnly = false
            mtkView.drawableSize = mtkView.frame.size
            //  mtkView.depthStencilPixelFormat = MTLPixelFormat(rawValue: 1)
            mtkView.clearDepth = 0.0;
            
        default:
            mtkView.preferredFramesPerSecond = 60
            mtkView.enableSetNeedsDisplay = true
            mtkView.isPaused = true
            mtkView.framebufferOnly = false
            mtkView.drawableSize = mtkView.frame.size
        }
        
       
        
        return mtkView
        
    }
    
    //Se llama para actualizar la vista
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
        //NSViewRepresentableContext<MetalViewMac>.self
        
        mtkView.drawableSize = nsView.frame.size
    }
    
    
 
}



//struct MetalViewMac_Previews: PreviewProvider {
//    static var previews: some View {
//        MetalViewMac(vistaActiva: VistaActiva.triangle1).environmentObject(ApplicationData())
//    }
//}
#endif
