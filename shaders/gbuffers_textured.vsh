#version 460 compatibility
#define GBUFFER TEXTURED
#define VERTEX

attribute vec4 at_tangent;

out vec3 normal;
out vec3 diffuse;
out vec2 texcoord;
out vec2 lmcoord;
out mat3 tbn;

void main()
{
    gl_Position = ftransform();

    normal = gl_Normal;
    diffuse = gl_Color.rgb;
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).st;

    vec3 tangent = normalize(at_tangent.xyz);
    vec3 binormal = cross(tangent, normal) * sign(at_tangent.w);
    tbn = mat3(tangent, binormal, normal);
}
