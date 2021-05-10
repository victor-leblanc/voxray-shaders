#version 460 compatibility
#define COMPOSITE DEFERRED
#define FRAGMENT

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;

uniform vec3 moonPosition;
uniform vec3 sunPosition;
uniform vec3 upPosition;

#include "program/common.glsl"

/* DRAWBUFFERS:0 */

void main()
{
    vec3 color = texture2D(colortex0, texcoord).rgb;
    float depth = texture2D(depthtex0, texcoord).x;

    computecommon(color, depth, false);

    gl_FragData[0] = vec4(color, 1.);
}
