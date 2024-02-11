//
//  shadersMesh.metal
//  p4
//
//  Created by Alejandro Garcia on 26/2/23.
//

#include <metal_stdlib>
using namespace metal;
#include "definitions.metal"

//MARK: MESH1
//Vertex shader
[[vertex]] VertexOutput vertexMesh1(const VertexInMesh vertex_in [[ stage_in ]],
    constant ArgumentDataMesh  &argumentData [[ buffer(1) ]],
    unsigned int vid [[vertex_id]])
{

    VertexOutput output;
    
    output.position =  argumentData.projection * argumentData.modelview * vertex_in.position;
    
    float fcolor = vid / 10000.0;
    float4 f4_color = float4(1-fcolor, 0, 0+fcolor, 1);
    
    output.color = f4_color;
    return output;
}


//Fragment shader
[[fragment]] float4 fragmentMesh1(VertexOutput input [[stage_in]]) {
  
    return input.color;
}


//MARK: MESH2

//Vertex shader
[[vertex]] VertexOutput vertexMesh2(const VertexInMesh vertex_in [[ stage_in ]],
    constant ArgumentDataMesh  &argumentData [[ buffer(1) ]],
    unsigned int vid [[vertex_id]])
{

    VertexOutput output;
    
    output.position =  argumentData.projection * argumentData.modelview * vertex_in.position;
    
    float fcolor = vid / 10000.0;
    float4 f4_color = float4(1-fcolor/2, 0.7-fcolor, 0+fcolor, 1);
    
    output.color = f4_color;
    return output;
}


//Fragment shader
[[fragment]] float4 fragmentMesh2(VertexOutput input [[stage_in]]) {
  
    return input.color;
}
