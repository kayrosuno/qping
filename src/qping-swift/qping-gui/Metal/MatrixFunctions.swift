//
//  MarixFunctions.swift
//  p4
//
//  Created by Alejandro Garcia on 26/2/23.
//

import Foundation
import simd

struct MatrixFunctions {
    static func makeTranslationMatrix(tx: Float, ty: Float) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        
        matrix[2, 0] = tx
        matrix[2, 1] = ty
        
        return matrix
    }
    
    //rota en el eje z
    static func makeRotationZMatrix(angle: Float) -> simd_float3x3 {
        let rows = [
            simd_float3(cos(angle), -sin(angle), 0),
            simd_float3(sin(angle), cos(angle), 0),
            simd_float3(0,          0,          1)
        ]
        
        return float3x3(rows: rows)
    }
    
    
    static func rotationAboutAxis(_ axis: simd_float4, byAngle angle: Float32) -> simd_float4x4
    {
        var mat =  matrix_identity_float4x4
        let c = cos(angle)
        let s = sin(angle)
        mat[0].x = axis.x * axis.x + (1 - axis.x * axis.x) * c
        mat[0].y = axis.x * axis.y * (1 - c) - axis.z * s
        mat[0].z = axis.x * axis.z * (1 - c) + axis.y * s
        mat[1].x = axis.x * axis.y * (1 - c) + axis.z * s
        mat[1].y = axis.y * axis.y + (1 - axis.y * axis.y) * c
        mat[1].z = axis.y * axis.z * (1 - c) - axis.x * s
        mat[2].x = axis.x * axis.z * (1 - c) - axis.y * s
        mat[2].y = axis.y * axis.z * (1 - c) + axis.x * s
        mat[2].z = axis.z * axis.z + (1 - axis.z * axis.z) * c
        return mat
        
    }
    
    //crea una matriz de perspectiva proyeccion
    static func perspectiveProjection(_ aspect: Float,
                               fieldOfViewY: Float,
                               near: Float,
                               far: Float) -> matrix_float4x4
    {
        var mat = matrix_float4x4()
        
        let fovRadians = fieldOfViewY * Float(.pi / 180.0)
        
        let yScale = 1 / tan(fovRadians * 0.5)
        let xScale = yScale / aspect
        let zRange = far - near
        let zScale = -(far + near) / zRange
        let wzScale = -2 * far * near / zRange
        
        mat[0].x = xScale
        mat[1].y = yScale
        mat[2].z = zScale
        mat[2].w = -1
        mat[3].z = wzScale
        
        return mat;
    }
    
    
    static func makeScaleMatrix(xScale: Float, yScale: Float) -> simd_float4x4 {
        let rows = [
            simd_float4(xScale,      0, 0, 0),
            simd_float4(     0, yScale, 0, 0),
            simd_float4(     0,      0, 1, 0),
            simd_float4(     0,      0, 0, 1)
        ]
        
        return float4x4(rows: rows)
    }
}
