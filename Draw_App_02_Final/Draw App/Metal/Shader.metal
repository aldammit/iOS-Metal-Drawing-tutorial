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

fragment float4 pointShaderFragment(PointVertex point_data [[ stage_in ]],
                                                    float2 pointCoord  [[ point_coord ]])
{
    float dist = length(pointCoord - float2(0.5));
    if (dist >= 0.5) {
        return float4(0);
    }
    return point_data.color;
};

struct TexturePipelineRasterizerData
{
    float4 position [[position]];
    float2 texcoord;
};

struct TextureVertex
{
    float2 position;
    float2 texcoord;
};


// Vertex shader which adjusts positions by an aspect ratio and passes texture
// coordinates through to the rasterizer.
vertex TexturePipelineRasterizerData textureVertexShader(const uint vertexID [[ vertex_id ]],
                                                         const device TextureVertex *vertices [[ buffer(0) ]])
{
    TexturePipelineRasterizerData out;

    out.position = vector_float4(vertices[vertexID].position.x, vertices[vertexID].position.y, 0.0, 1.0);
    
    out.texcoord = vertices[vertexID].texcoord;
    return out;
}

fragment float4 textureFragmentShader(TexturePipelineRasterizerData in [[stage_in]], texture2d<float> texture [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 colorSample = float4(texture.sample(textureSampler, in.texcoord));
    return colorSample;
}

kernel void alphaBlend(texture2d<half, access::write> outputTexture [[texture(0)]],
                         texture2d<half, access::read> inputTexture [[texture(1)]],
                         texture2d<half, access::sample> inputTexture2 [[texture(2)]],
                         constant float *mixturePercent [[buffer(0)]],
                         uint2 grid [[thread_position_in_grid]]) {
    
    const half4 inColor = inputTexture.read(grid);
    constexpr sampler quadSampler(mag_filter::linear, min_filter::linear);

    const half4 inColor2 = inputTexture2.sample(quadSampler, float2(float(grid.x) / outputTexture.get_width(), float(grid.y) / outputTexture.get_height()));
    const half4 outColor(mix(inColor.rgb, inColor2.rgb, inColor2.a * half(*mixturePercent)), inColor.a);

    outputTexture.write(outColor, grid);
}

kernel void maskingBlend(texture2d<float, access::write> outputTexture [[texture(0)]],
                         texture2d<float, access::read> inputTexture1 [[texture(1)]],
                         texture2d<float, access::read> inputTexture2 [[texture(2)]],
                         uint2 gid [[thread_position_in_grid]])
 {
     if (gid.x < inputTexture1.get_width() && gid.y < inputTexture1.get_height()) {
         float4 pixel1 = inputTexture1.read(gid);
         float4 pixel2 = inputTexture2.read(gid);

         if (pixel2.a > 0.0) {
             pixel1 = float4(pixel1.rgb, 0.0);
         }

         outputTexture.write(pixel1, gid);
     }
 }
