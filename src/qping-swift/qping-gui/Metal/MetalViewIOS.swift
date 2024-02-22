//
//  MetalViewIOS.swift
//  p4
//
//  Created by Alejandro Garcia on 2/2/23.
//

#if canImport(UIKit)
import SwiftUI
import MetalKit
import UIKit


struct MetalViewIOS: UIViewRepresentable  {
    typealias UIViewType = UIView
    //@EnvironmentObject  var appData: ApplicationData
    var tipoRender:TipoRenderGPU = TipoRenderGPU.Triangle_1
    
    /// Custom UIView
    let mtkView = MTKViewCustom()
    
    //Constructor
    init(tipoRender: TipoRenderGPU)
    {
        self.tipoRender = tipoRender
        mtkView.isMultipleTouchEnabled = true //reconocer multitouch
    }
    
    //Crear el coordinador que actualiza la vista
    func makeCoordinator()  -> MTKViewDelegate{
        switch(tipoRender)
        {
        case .Mesh_1:
            return RendererMesh1(self,tipoTest: tipoRender)
//        case .Mesh_2:
//            return RendererMesh2(self,tipoTest: tipoTest)
        default:
            return RendererTriangle(self,tipoTest: tipoRender)
        }
    }
    
    
    ///
    ///Devuelve un UIView sobre el que se realizará el render de Metal
    ///
    func makeUIView(context: UIViewRepresentableContext <MetalViewIOS>) ->  UIView {
        
        
        if let metalDevice = MTLCreateSystemDefaultDevice()
        {
            mtkView.device = metalDevice
        }
        mtkView.delegate = context.coordinator
        
        switch(tipoRender)
        {
            
            
        case .Triangle_3:
            mtkView.preferredFramesPerSecond = 60
            mtkView.enableSetNeedsDisplay = false
            mtkView.isPaused = false
            mtkView.framebufferOnly = false
            mtkView.drawableSize = mtkView.frame.size
            
        case .Cubo_1:
            mtkView.preferredFramesPerSecond = 60
            mtkView.enableSetNeedsDisplay = false
            mtkView.isPaused = false
            mtkView.framebufferOnly = false
            mtkView.drawableSize = mtkView.frame.size
            //  mtkView.depthStencilPixelFormat = MTLPixelFormat(rawValue: 1)
            mtkView.clearDepth = 0.0;
            
        case .Mesh_1:
            mtkView.preferredFramesPerSecond = 60
            mtkView.enableSetNeedsDisplay = false
            mtkView.isPaused = false
            mtkView.framebufferOnly = false
            mtkView.drawableSize = mtkView.frame.size
            //  mtkView.depthStencilPixelFormat = MTLPixelFormat(rawValue: 1)
            mtkView.clearDepth = 0.0;
            mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
            mtkView.backgroundColor = UIColor.clear
            
        case .Mesh_2:
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
    
    ///
    /// Se llama para actualizar la vista
    ///
    func updateUIView(_ nsView: UIViewType, context: Context) {
        
        //NSViewRepresentableContext<MetalViewMac>.self
        
        mtkView.drawableSize = nsView.frame.size
    }
    
}


//struct MetalViewIOS_Previews: PreviewProvider {
//    static var previews: some View {
//        MetalViewIOS(tipoTest: TipoRenderGPU.triangle1).environmentObject(ApplicationData())
//    }
//}

#endif
