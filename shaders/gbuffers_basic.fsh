#version 460 compatibility
#define GBUFFER BASIC
#define FRAGMENT

in vec3 diffuse;

/* DRAWBUFFERS:0 */

void main()
{
    gl_FragData[0] = vec4(diffuse, 1.);
}