#version 460 compatibility
#define COMPOSITE COMPOSITE
#define VERTEX

out vec2 texcoord;

void main()
{
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;
}
