#version 460 compatibility
#define GBUFFER SHADOW
#define VERTEX

attribute vec3 mc_Entity;
attribute vec2 mc_midTexCoord;
attribute vec3 at_midBlock;

out vec4 color;
out vec2 texcoord;
out flat uint entityid;

#include "lib/space.glsl"
#include "lib/voxel.glsl"

#define DEFAULT_ENTITY_ID 10010 // cube non-emissive (see block.properties)

void main()
{
    color = gl_Color;
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;
    entityid = int(mc_Entity.x + 1e-3);
    if (entityid == 0) {
        entityid = DEFAULT_ENTITY_ID;
    }

    vec4 viewpos = (gl_ModelViewMatrix * gl_Vertex);
    vec3 worldpos = (shadowModelViewInverse * viewpos).xyz;

    vec3 voxelpos = floor(worldpos + at_midBlock / 64.);
    vec2 pixelpos = sign(texcoord - mc_midTexCoord.xy) / shadowMapResolution;

    vec2 packedvoxel = packvoxelposition(voxelpos) * 2. - 1. + pixelpos;
    gl_Position = vec4(packedvoxel, 0., 1.);

}