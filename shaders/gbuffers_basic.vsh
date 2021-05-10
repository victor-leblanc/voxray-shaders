#version 460 compatibility
#define GBUFFER BASIC
#define VERTEX

out vec3 diffuse;

void main()
{
    gl_Position = ftransform();
    diffuse = gl_Color.rgb;
}
