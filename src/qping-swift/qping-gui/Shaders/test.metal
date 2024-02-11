//
//  test.metal
//  metalTest1
//
//  Created by Alejandro Garcia on 7/1/23.
//

#include <metal_stdlib>
using namespace metal;
#include "definitions.metal"

/**  Funcion que suma dos arrys*/
kernel void add_arrays(device const float* inA,
                       device const float* inB,
                       device float* result,
                       uint index [[thread_position_in_grid]])
{
    // the for-loop is replaced with a collection of threads, each of which
    // calls this function.
    result[index] = inA[index] + inB[index];
}


//
//vertex VertexOut myVertexShader(const global Vertex* vertexArray [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
//    VertexOut out;
//    out.position = vertexArray[vid].position;
//    out.color = vertexArray[vid].color;
//    return out;
//}
//
//fragment float4 myFragmentShader(VertexOut interpolated [[stage_in]])
//{
//    return interpolated.color;
//}
//
//struct Uniforms {
//    float4x4 mvp_matrix;
//};
//
//vertex VSOut vertexShader(const global Vertex* vertexArray [[ buffer(0) ]], constant Uniforms& uniforms [[ buffer(1) ]],unsigned int vid [[ vertex_id]]) {
//    VSOut out;
//    out.position = uniforms.mvp_matrix * vertexArray[vid].position;
//    out.color = half4(vertexArray[vid].color);
//    return out;
//}
