texture2d image_previous;                 // previous frame of the source texture (same frame or blank if initialized)
texture2d target_previous;                // shader output from the previous frame (as above)

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    return image.Sample(builtin_texture_sampler, uv);
}