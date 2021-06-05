#version 460 compatibility

layout (local_size_x = 2, local_size_y = 2) in;

const vec2 workGroupsRender = vec2(1.0f, 1.0f);

uniform sampler2D colortex0;

layout (rgba8) uniform image2D colorimg0;

void main()
{
    ivec2 iuv = ivec2(gl_GlobalInvocationID.xy);

    ivec2 resfactor = ivec2(1.f / workGroupsRender);
    ivec2 scaleduv = iuv * resfactor;

    vec3 color = texelFetch(colortex0, scaleduv, 0).rgb;
    
    for (uint x = 0; x < resfactor.x; x++) {
        for (uint y = 0; y < resfactor.y; y++) {
            imageStore(colorimg0, scaleduv + ivec2(x, y), vec4(color, 1.0));
        }
    }
}
