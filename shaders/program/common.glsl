#ifndef COMMON_PROGRAM_COMMON
#define COMMON_PROGRAM_COMMON

    struct Light {
        vec3 position;
        vec3 color;
        float strength; // -1 = infinite (sun, moon)
    };

    void computecommon(inout vec3 color, in float depth, in bool water) {
        vec3 normal = texture2D(colortex1, texcoord).rgb;

        vec3 ndcpos = vec3(texcoord, depth);
        vec3 viewpos = ndctoview(ndcpos);
        vec3 worldpos = mat3(gbufferModelViewInverse) * viewpos;
        vec3 playerpos = .5 - fract(-cameraPosition + .5) + gbufferModelViewInverse[3].xyz;
        vec3 voxelpos = worldpos + playerpos;
        vec3 moonpos = mat3(gbufferModelViewInverse) * moonPosition;
        vec3 sunpos = mat3(gbufferModelViewInverse) * sunPosition;

        vec3 normworldpos = normalize(worldpos);
        vec3 normmoonpos = normalize(moonpos);
        vec3 normsunpos = normalize(sunpos);

        float ndotu = dot(normal, normworldpos);
        float ndotmoon = dot(normal, normmoonpos);
        float ndotsun = dot(normal, normsunpos);

        // reflections
        Voxel voxreflection = voxeltrace(voxelpos, reflect(normworldpos, normal));
        vec3 reflection = mix(vec3(.6, .8, 1.), voxreflection.color.rgb, voxreflection.color.a);
        color = mix(color, reflection, max(1. - abs(ndotu), 0.) * (water ? .5 : .1));

        // light
        Light moon = Light(moonpos, vec3(.1, .2, .3), -1);
        Light sun = Light(sunpos, vec3(1.), -1.);

        // shadows
        float dither = bayer16(texcoord * vec2(viewWidth, viewHeight));
        Voxel voxshadow = voxeltrace(voxelpos, normalize(sunpos + (dither * 2. - 1.) * 5.));
        vec3 diffuse = mix(vec3(1.2, 1.1, 1.), vec3(.4, .5, .6), min(max(voxshadow.color.a, 1. - ndotsun), 1.));
        color *= diffuse;

        // volumetric
        Voxel voxvl = voxeltrace(worldpos * dither + playerpos, normsunpos);
        color = mix(color, vec3(1.2, 1.1, 1.), (1. - voxvl.color.a) * .2);
    }

#endif