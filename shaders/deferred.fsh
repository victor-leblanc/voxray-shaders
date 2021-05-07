#version 460 compatibility
#define COMPOSITE
#define FRAGMENT

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;

uniform vec3 moonPosition;
uniform vec3 sunPosition;

#include "lib/sample.glsl"
#include "lib/space.glsl"
#include "lib/voxel.glsl"
#include "program/common.glsl"

/* DRAWBUFFERS:0 */

void main()
{
    vec3 color = texture2D(colortex0, texcoord).rgb;
    float depth = texture2D(depthtex0, texcoord).x;

    computecommon(color, depth, false);

/*
    Voxel v = voxeltrace(voxelpos, fragpos);
    color = v.color.rgb;
*/

    gl_FragData[0] = vec4(color, 1.);
}
