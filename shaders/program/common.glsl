#define MAX_LIGHTS 8

#ifndef COMMON_PROGRAM_COMMON
#define COMMON_PROGRAM_COMMON

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

        vec3 normworldpos = normalize(worldpos);
        float dither = bayer16(texcoord * vec2(viewWidth, viewHeight));

        // reflections
        Voxel voxreflection = voxeltrace(voxelpos, reflect(normworldpos, normal));
        vec3 reflection = mix(vec3(.6, .8, 1.), voxreflection.property.color.rgb, voxreflection.property.color.a);
        color = mix(color, reflection, max(1. - abs(dot(normal, normworldpos)), 0.) * (water ? .5 : .1));

        // light
        Light lightnone = Light(vec3(0.), vec3(0.), 0., 0.);
        Light sun = Light(sunpos, vec3(1.), 1., -1.);
        Light moon = Light(moonpos, vec3(.6, .8, 1.), .1, -1);

        Light[MAX_LIGHTS] lightlist = Light[MAX_LIGHTS](sun, lightnone, lightnone, lightnone, lightnone, lightnone, lightnone, lightnone);
        vec3 diffuse = vec3(0.);
        for (uint i = 0u; i < MAX_LIGHTS; i++) {
            Light light = lightlist[i];
            if (light.strength == lightnone.strength) {
                break;
            }
            vec3 normlightpos = normalize(light.position);
            float ndotl = dot(normal, normlightpos);

            // shadows
            vec3 ditheredlightpos = normalize(light.position + (dither * 2. - 1.) * 3.);
            Voxel voxshadow = voxeltrace(voxelpos, ditheredlightpos);
            diffuse += normalize(light.color) * (light.strength * (1. - min(max(voxshadow.property.color.a, 1. - ndotl), 1.)));

            /*
            // volumetric
            Voxel voxvl = voxeltrace(worldpos * dither + playerpos, normlightpos);
            color = mix(color, vec3(1.2, 1.1, 1.), (1. - voxvl.property.color.a) * .2);
            */
            
        }
        color = mix(color / 3., color * 1.5, diffuse);

        //Voxel v = voxeltrace(voxelpos, normworldpos);
        //color = v.property.color.rgb;
    }

#endif