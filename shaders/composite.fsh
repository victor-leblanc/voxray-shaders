#version 460 compatibility
#define COMPOSITE
#define FRAGMENT

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform vec3 moonPosition;
uniform vec3 sunPosition;

#define RGBA32F 0
const int colortex1Format = RGBA32F;
const vec4 shadowcolor0ClearColor = vec4(0., 0., 0., 0.);
const float ambientOcclusionLevel = 0.;
const float sunPathRotation = 32f; 

#include "lib/sample.glsl"
#include "lib/space.glsl"
#include "lib/voxel.glsl"
#include "program/common.glsl"

/* DRAWBUFFERS:0 */

void main()
{
    vec3 color = texture2D(colortex0, texcoord).rgb;

    float depth0 = texture2D(depthtex0, texcoord).x;
    float depth1 = texture2D(depthtex1, texcoord).x;
    bool water = depth0 < depth1;
    if (water) {
        computecommon(color, depth0, true);
    }

    gl_FragData[0] = vec4(color, 1.);
}
