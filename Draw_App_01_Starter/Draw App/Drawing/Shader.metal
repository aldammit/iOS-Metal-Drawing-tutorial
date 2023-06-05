//
//  Shader.metal
//  Draw App
//
//  Created by Bogdan Redkin on 06/05/2023.
//

#include <metal_stdlib>
using namespace metal;

struct PointVertex {
    float4 position [[position]];
    float4 color;
    float size [[point_size]];
};
