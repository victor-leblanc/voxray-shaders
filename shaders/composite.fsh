#version 460 compatibility
#extension GL_EXT_gpu_shader4 : enable
#define COMPOSITE COMPOSITE
#define FRAGMENT

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D shadowcolor0;

uniform float aspectRatio;

const vec4 shadowcolor0ClearColor = vec4(0., 0., 0., 0.);
const int shadowMapResolution = 3072;

/* DRAWBUFFERS:0 */

void main()
{
    vec3 color = texture2D(colortex0, texcoord).rgb;
    vec3 voxelmap = texelFetch(shadowcolor0, ivec2(texcoord * shadowMapResolution), 0).rgb;

    gl_FragData[0] = vec4(mix(color, voxelmap, 0.5), 1.);
}
