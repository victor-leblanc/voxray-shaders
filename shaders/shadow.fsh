#version 120

uniform sampler2D texture;

varying vec4 color;
varying vec2 texcoord;

/* DRAWBUFFERS:0 */

void main()
{
    gl_FragData[0] = color * texture2D(texture, texcoord);
}
