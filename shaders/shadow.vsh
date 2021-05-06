#version 460 compatibility
#define GBUFFER
#define VERTEX

attribute float mc_Entity;
attribute vec2 mc_midTexCoord;
attribute vec3 at_midBlock;

out vec4 color;
out vec2 texcoord;

#include "lib/space.glsl"
#include "lib/voxel.glsl"

void main()
{
    color = gl_Color;
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;

    if (mc_Entity.x == 1.) {
        gl_Position = vec4(0.);
    } else {
        vec4 viewpos = (gl_ModelViewMatrix * gl_Vertex);
        vec3 worldpos = (shadowModelViewInverse * viewpos).xyz;

        vec3 voxelpos = floor(worldpos + at_midBlock / 64.);
        vec2 pixelpos = sign(texcoord - mc_midTexCoord.xy) / shadowMapResolution;

        vec2 packedvoxel = pack_voxelmap(voxelpos) * 2. - 1. + pixelpos;
        gl_Position = vec4(packedvoxel, 0., 1.);
    }
}
