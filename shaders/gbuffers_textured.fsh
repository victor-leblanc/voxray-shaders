#version 460 compatibility
#define GBUFFER
#define FRAGMENT

in vec3 normal;
in vec3 diffuse;
in vec2 texcoord;
in vec2 lmcoord;
in mat3 tbn;

uniform sampler2D texture;
uniform sampler2D normals;
uniform sampler2D specular;
uniform sampler2D lightmap;

#include "lib/voxel.glsl"

/* DRAWBUFFERS:02 */

#define NORMAL_STRENGTH 0.25

void main()
{
    vec4 color = texture2D(texture, texcoord);
    color.rgb *= texture2D(lightmap, lmcoord).rgb * diffuse;

    vec4 texnormal = texture2D(normals, texcoord);
    vec3 decnormal = normalize(vec3(texnormal.rg, sqrt(1. - dot(texnormal.rg, texnormal.rg))) * 2. - 1.);
    vec3 finalnormal = mix(normal, tbn * decnormal, NORMAL_STRENGTH);



    gl_FragData[0] = color;
    gl_FragData[1] = vec4(finalnormal * .5 + .5, 1.);
}