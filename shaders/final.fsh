#version 460 compatibility

uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D shadowcolor0;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPosition;
uniform vec3 shadowLightPosition;

uniform float near;
uniform float far;

in vec2 texcoord;

#include "lib/voxel.glsl"

/*
const vec4 shadowcolor0ClearColor = vec4(0., 0., 0., 0.);
const float ambientOcclusionLevel = 0.;
const float sunPathRotation = 32f; 
*/

vec3 depth(sampler2D d, vec2 c)
{
    vec3 screenPos = vec3(c, texture2D(d, c).r);
    vec3 clipPos = screenPos * 2.0 - 1.0;
    vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
    vec3 viewPos = -tmp.xyz / tmp.w;

    return viewPos;
}

struct Voxel {
    vec4 color;
    vec3 position;
    //vec3 nor;
};

Voxel raytrace(vec3 p, vec3 d)
{
    vec3 s = sign(d);
    vec3 r = s / d;
    vec3 m = p;
    vec4 t = vec4(0.);

    for (int i = 0; i < 100; i++) {
        vec3 f = fract(-m * s);
        f = max(f, 1. - fract(m * s)) * r;
        vec3 b = min(f.xxx, min(f.yyy, f.zzz));
        m += d * b;

        vec2 u = pack_voxelmap(floor(m + d * step(f, b)));

        if (u.x < -.5) break;
        //float l = dot(step(f,b),sqrt(vec3(.2,.5,.3)));
        vec4 st = texture2D(shadowcolor0,u);

        //f = fract(-m*s);
        //f = max(f,step(f,vec3(1e-62)))*r;
        //st.a *= pow(min(f.x,min(f.y,f.z)),3.-3.*st.a);
        t += st * (1. - t.a);
        if (t.a >= 1.) break;
    }

    //v.nor = s * vec3(equal(m, floor(m)));
    return Voxel(t, m);
}

/* DRAWBUFFERS:0 */

void main()
{
    vec3 color = texture2D(gcolor, texcoord).rgb;
    vec3 normal = texture2D(gnormal, texcoord).rgb * 2. - 1.;

    vec4 ndc = gbufferProjectionInverse * vec4(texcoord * 2. - 1., 1., 1.);
    ndc = gbufferModelViewInverse * vec4(ndc.xyz / ndc.w, 1.);
    vec3 fragpos = normalize(ndc.xyz);
    float ndotu = dot(normal, fragpos);

    vec3 feetoffset = gbufferModelViewInverse[3].xyz;
    vec3 playerpos = .5 - fract(-cameraPosition + .5) + feetoffset;

    vec3 depth0 = depth(depthtex0, texcoord);
    vec3 depth1 = depth(depthtex1, texcoord);
    bool water = depth0.z < depth1.z;
    vec3 worldpos = fragpos * length(depth0) + playerpos;

    vec3 lightpos = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);
    float ndotl = dot(normal, lightpos);

    Voxel voxshadow = raytrace(worldpos, lightpos);
    vec3 diffuse = mix(vec3(1.2, 1.1, 1.), vec3(.4, .5, .6), min(max(voxshadow.color.a, 1. - ndotl), 1.));
    color *= diffuse;

    Voxel voxreflection = raytrace(worldpos, reflect(fragpos, normal));
    vec3 reflection = mix(vec3(.6, .8, 1.), voxreflection.color.rgb, voxreflection.color.a);
    color = mix(color, reflection, (1. - abs(ndotu)) * (water ? 1. : .1));

    //Voxel v = raytrace(worldpos, fragpos);
    //color = v.color.rgb;

    gl_FragData[0] = vec4(color, 1.);
}
