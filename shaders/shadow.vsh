#version 120

attribute float mc_Entity;
attribute vec2 mc_midTexCoord;
attribute vec3 at_midBlock;

uniform mat4 shadowModelViewInverse;

varying vec4 color;
varying vec2 texcoord;

#include "lib/voxel.glsl"

void main()
{
    color = gl_Color;
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    vec4 viewPos = (gl_ModelViewMatrix * gl_Vertex);
    vec3 worldPos = (shadowModelViewInverse * viewPos).xyz;

    vec3 voxel = floor(worldPos + at_midBlock / 64.);
    vec2 pixelCoords = sign(texcoord - mc_midTexCoord.xy) / shadowMapResolution;

    vec2 u = pack_voxelmap(voxel) * 2. - 1. + pixelCoords;
    gl_Position = vec4(u, 0., 1.) - float(mc_Entity == 1.);
}
