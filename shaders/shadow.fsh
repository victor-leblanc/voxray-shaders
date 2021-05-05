#version 460 compatibility

uniform sampler2D texture;

in vec4 color;
in vec2 texcoord;

/* DRAWBUFFERS:0 */

void main()
{
    gl_FragData[0] = color * texture2D(texture, texcoord);
}
