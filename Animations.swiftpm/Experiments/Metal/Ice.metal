#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// Adapted from Bookshelf's "Freezing a View Over with Ice" tutorial.
// Voronoi controls WHEN the photo-derived material appears, not its crystal shape.
static float iceHash(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

static float2 iceField(float2 uv) {
    float2 p = uv * 7.0, cell = floor(p);
    float total = 0, weight = 0, nearest = 10;
    for (int y = -1; y <= 1; ++y) {
        for (int x = -1; x <= 1; ++x) {
            float2 c = cell + float2(x, y);
            float random = iceHash(c);
            float2 feature = c + float2(random, iceHash(c + random));
            float distance = length(p - feature);
            nearest = min(nearest, distance);
            float2 q = feature / 7.0;
            float edge = min(min(q.x, 1 - q.x), min(q.y, 1 - q.y));
            float activation = saturate(edge * 2 + (iceHash(c + 7) - 0.5) * 0.35);
            float w = exp(-distance * 4);
            total += activation * w;
            weight += w;
        }
    }
    return float2(total / weight, nearest);
}

[[ stitchable ]] half4 iceGlass(float2 position, SwiftUI::Layer layer,
                               float2 size, float season, float density,
                               texture2d<half> colorMap, texture2d<half> reliefMap,
                               device const float *touches, int touchFloatCount) {
    constexpr sampler material(filter::linear, address::clamp_to_edge);
    float2 uv = position / max(size, float2(1));
    if (season <= 0.0001) return layer.sample(position);
    // Identical, aspect-preserving coordinates for all material channels.
    float2 mapUV = uv - 0.5;
    float aspect = size.x / max(size.y, 1.0);
    if (aspect > 0.75) mapUV.y *= 0.75 / aspect;
    else mapUV.x *= aspect / 0.75;
    mapUV += 0.5;
    float3 packed = float3(reliefMap.sample(material, mapUV).rgb);
    float height = packed.r;
    float2 nxy = packed.gb * 2 - 1;
    float3 normal = normalize(float3(nxy.x, -nxy.y, sqrt(max(0.001, 1 - dot(nxy, nxy)))));
    float heat = 0;
    for (int i = 0; i + 3 < touchFloatCount; i += 4) {
        float2 d = (uv - float2(touches[i], touches[i + 1])) * float2(aspect, 1) / 0.12;
        float d2 = dot(d, d);
        if (d2 < 1) {
            float disc = 1 - d2;
            float cooling = exp(-max(0.0, touches[i + 3] - 2.0) * 1.4);
            heat += touches[i + 2] * disc * disc * cooling;
        }
    }
    float2 field = iceField(uv);
    float local = smoothstep(field.x, field.x + 0.30, season * 1.5);
    float threshold = max(1 - local, saturate(heat));
    float reveal = smoothstep(threshold, threshold + 0.25, height);
    float mound = pow(1 - smoothstep(0.0, 0.7, field.y), 1.5);
    float thickness = reveal * saturate(0.4 * mound + 0.6 * height) * density;
    float2 bend = normal.xy * size * 0.30 * thickness;
    half4 background = layer.sample(clamp(position + bend, float2(0.5), size - 0.5));
    half3 ice = colorMap.sample(material, mapUV).rgb;
    float opacity = saturate(thickness / 0.8);
    opacity = max(opacity, smoothstep(0.8, 1.0, reveal) * density);
    half3 rgb = mix(background.rgb, ice * background.a, half(opacity));
    float3 light = normalize(float3(-0.45, -0.6, 1.0));
    float sparkle = pow(max(dot(normal, normalize(light + float3(0, 0, 1))), 0.0), 48.0);
    float fresnel = pow(1 - saturate(normal.z), 3.0);
    rgb += half3((sparkle * 0.16 + fresnel * 0.12) * thickness) * background.a;
    return half4(rgb, background.a);
}
