#define MAX_LIGHTS 2

#ifndef COMMON_PROGRAM_COMMON
#define COMMON_PROGRAM_COMMON

    #include "../lib/sample.glsl"
    #include "../lib/space.glsl"
    #include "../lib/std.glsl"
    #include "../lib/voxel.glsl"

    struct Light {
        vec3 position;
        vec3 color;
        float strength;
        float range; // -1 = infinite (sun, moon)
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
        vec3 uppos = mat3(gbufferModelViewInverse) * upPosition;

        vec3 normworldpos = normalize(worldpos);
        vec3 normuppos = normalize(uppos);
        float dither = bayer16(texcoord * vec2(viewWidth, viewHeight));

        // reflections
        Voxel voxreflection = voxeltrace(voxelpos, reflect(normworldpos, normal));
        vec3 reflection = mix(vec3(.6, .8, 1.), voxreflection.property.color.rgb, voxreflection.property.color.a);
        color = mix(color, reflection, max(1. - abs(dot(normal, normworldpos)), 0.) * (water ? .5 : .1));

        // light
        Light sun = Light(sunpos, vec3(1.), 1., -1.);
        Light moon = Light(moonpos, vec3(.6, .8, 1.), .2, -1.);

        Light[MAX_LIGHTS] lightlist;
        lightlist[0] = sun;
        lightlist[1] = moon;
        uint lightcount = 2u;

        // TODO : Light sampling

        vec3 diffuse = vec3(0.);
        for (uint i = 0u; i < lightcount; i++) {
            Light light = lightlist[i];
            vec3 normlightpos = normalize(light.position);
            vec3 normlightcolor = normalize(light.color);
            float ndotl = dot(normal, normlightpos);
            if (light.range < 0.) {
                light.strength *= clamp(pow(dot(normlightpos, normuppos) + .5, 2.), 0., 1.);
                if (light.strength < 1e-3) {
                    continue;
                }
            }

            // shadows
            vec3 ditheredlightpos = normalize(light.position + (dither * 2. - 1.) * 3.);
            Voxel voxshadow = voxeltrace(voxelpos, ditheredlightpos);
            diffuse += normlightcolor * (light.strength * (1. - min(max(voxshadow.property.color.a, 1. - ndotl), 1.)));

            // volumetric
            Voxel voxvl = voxeltrace(worldpos * dither + playerpos, normlightpos);
            diffuse = mix(diffuse, normlightcolor, (1. - voxvl.property.color.a) * light.strength);
        }
        color += diffuse;

        /*
        Voxel v = voxeltrace(voxelpos, normworldpos);
        color = vec3(v.property.light);
        */
    }

#endif