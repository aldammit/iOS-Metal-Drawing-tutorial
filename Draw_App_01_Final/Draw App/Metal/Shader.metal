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

vertex PointVertex pointShaderVertex(constant PointVertex *points [[ buffer(0) ]],
                                     uint vid [[ vertex_id ]])
{
    PointVertex out = points[vid];

    float2 pos = float2(out.position.x, out.position.y);
    out.position = float4(pos, 0, 1);
    return out;
};

fragment half4 pointShaderFragment(PointVertex point_data [[ stage_in ]],
                                                    float2 pointCoord  [[ point_coord ]])
{
    float dist = length(pointCoord - float2(0.5));
    float4 out_color = point_data.color;
    out_color.a = 1.0 - smoothstep(0.4, 0.5, dist);
    return half4(out_color);
};
