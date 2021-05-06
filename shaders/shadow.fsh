#version 460 compatibility
#define GBUFFER
#define FRAGMENT

in vec4 color;
in vec2 texcoord;

uniform sampler2D texture;

/* DRAWBUFFERS:0 */

void main()
{
    gl_FragData[0] = color * texture2D(texture, texcoord);
}
