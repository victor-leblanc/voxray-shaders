#version 460 compatibility
#define GBUFFER SHADOW
#define FRAGMENT

in vec3 color;
in vec2 texcoord;

/* DRAWBUFFERS:0 */

void main()
{
    gl_FragData[0] = vec4(color, 1.);
}
