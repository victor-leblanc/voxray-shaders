#version 460 compatibility
#define COMPOSITE
#define FRAGMENT

in vec2 texcoord;

uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D noisetex;

uniform vec3 moonPosition;
uniform vec3 sunPosition;

const vec4 shadowcolor0ClearColor = vec4(0., 0., 0., 0.);
const float ambientOcclusionLevel = 0.;
const float sunPathRotation = 32f; 
const int noiseTextureResolution = 128;

#include "lib/space.glsl"
#include "lib/voxel.glsl"

/* DRAWBUFFERS:0 */

void main()
{
    vec3 color = texture2D(gcolor, texcoord).rgb;

    float depth0 = texture2D(depthtex0, texcoord).x;
    float depth1 = texture2D(depthtex1, texcoord).x;
    bool water = depth0 < depth1;
    if (water) {
        vec3 normal = texture2D(gnormal, texcoord).rgb * 2. - 1.;

        vec3 ndcpos = vec3(texcoord, depth0);
        vec3 viewpos = ndctoview(ndcpos);
        vec3 worldpos = mat3(gbufferModelViewInverse) * viewpos;
        vec3 voxelpos = worldpos + .5 - fract(-cameraPosition + .5) + gbufferModelViewInverse[3].xyz;
        vec3 moonpos = mat3(gbufferModelViewInverse) * moonPosition;
        vec3 sunpos = mat3(gbufferModelViewInverse) * sunPosition;

        vec3 normworldpos = normalize(worldpos);
        vec3 normmoonpos = normalize(moonpos);
        vec3 normsunpos = normalize(sunpos);

        float ndotl = dot(normal, normsunpos);
        float ndotu = dot(normal, normworldpos);

        float depth0 = ndcpos.z;
        float depth1 = texture2D(depthtex1, texcoord).x;
        bool water = depth0 < depth1;

        vec3 noise = texture2D(noisetex, voxelpos.xz + voxelpos.y).xyz * 2. - 1.;
        Voxel voxshadow = raytrace(voxelpos, normalize(sunpos + noise * 5.));
        vec3 diffuse = mix(vec3(1.2, 1.1, 1.), vec3(.4, .5, .6), min(max(voxshadow.color.a, 1. - ndotl), 1.));
        color *= diffuse;

        Voxel voxreflection = raytrace(voxelpos, reflect(normworldpos, normal));
        vec3 reflection = mix(vec3(.6, .8, 1.), voxreflection.color.rgb, voxreflection.color.a);
        color = mix(color, reflection, (1. - abs(ndotu)) * 0.5);
    }

/*
    Voxel v = raytrace(voxelpos, fragpos);
    color = v.color.rgb;
*/

    gl_FragData[0] = vec4(color, 1.);
}
