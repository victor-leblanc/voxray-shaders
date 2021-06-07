#version 460 compatibility
#define GBUFFER SHADOW
#define VERTEX

in vec3 mc_Entity;
in vec2 mc_midTexCoord;
in vec3 at_midBlock;

out vec3 color;
out vec2 texcoord;

#include "lib/space.glsl"

const int shadowMapResolution = 3072;
const ivec3 voxelMapResolution = ivec3(96, 32, 96);

void main()
{
    color = gl_Color.rgb;
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;

    vec4 viewpos = gl_ModelViewMatrix * gl_Vertex;
    vec3 worldpos = (shadowModelViewInverse * viewpos).xyz;
    ivec3 voxelpos = ivec3(worldpos + at_midBlock / 64.);

    ivec3 midvoxmap = voxelMapResolution / 2;
    
    if (any(lessThan(voxelpos, -midvoxmap)) || any(greaterThan(voxelpos, midvoxmap))) { // voxel out of bound
        gl_Position = vec4(0.);
    } else {
        voxelpos += midvoxmap;
        vec2 pixelpos = voxelpos.xz;

        pixelpos /= shadowMapResolution;
        pixelpos = pixelpos * 2. - 1.;
        gl_Position = vec4(pixelpos, 0., 1.);
    }
}