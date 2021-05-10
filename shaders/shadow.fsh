#version 460 compatibility
#define GBUFFER SHADOW
#define FRAGMENT

in vec4 color;
in vec2 texcoord;
in flat uint entityid;

uniform sampler2D texture;

#include "lib/voxel.glsl"

/* DRAWBUFFERS:0 */

void main()
{
    vec4 voxcolor = color * texture2D(texture, texcoord);
    vec3 packedvoxel = packvoxelproperty(entityid, voxcolor);
    gl_FragData[0] = vec4(packedvoxel, 1.);
}
