#ifndef COMMON_LIB_SPACE
#define COMMON_LIB_SPACE

    uniform mat4 gbufferModelView;
    uniform mat4 gbufferModelViewInverse;
    uniform mat4 gbufferPreviousModelView;
    uniform mat4 gbufferProjection;
    uniform mat4 gbufferProjectionInverse;
    uniform mat4 gbufferPreviousProjection;
    uniform mat4 shadowProjection;
    uniform mat4 shadowProjectionInverse;
    uniform mat4 shadowModelView;
    uniform mat4 shadowModelViewInverse; 

    uniform vec3 cameraPosition;
    uniform vec3 previousCameraPosition;
    uniform float viewWidth;
    uniform float viewHeight;
    uniform float near;
    uniform float far;

    /* standard space conversion */
    vec3 ndctoview(in vec3 ndcpos) {
        vec4 viewpos = gbufferProjectionInverse * vec4(ndcpos * 2. - 1., 1.);
        return viewpos.xyz / viewpos.w;
    }

    vec3 ndctoprev(in vec3 ndcpos) {
        vec4 prevpos = gbufferProjectionInverse * vec4(ndcpos * 2. - 1., 1.);
        prevpos = gbufferModelViewInverse * prevpos;
        prevpos.xyz += cameraPosition - previousCameraPosition;
        prevpos = gbufferPreviousModelView * prevpos;
        prevpos = gbufferPreviousProjection * prevpos;
        return prevpos.xyz / prevpos.w;
    }

    vec3 ndctoshadow(in vec3 ndcpos) {
        vec4 shadowpos = gbufferProjectionInverse * vec4(ndcpos * 2. - 1., 1.);
        shadowpos = gbufferModelViewInverse * shadowpos;
        shadowpos = shadowModelView * shadowpos;
        shadowpos = shadowProjection * shadowpos;
        return shadowpos.xyz / shadowpos.w;
    }

    vec3 viewtondc(in vec3 viewpos) {
        vec3 ndcpos = mat3(gbufferProjection) * viewpos + gbufferProjection[3].xyz;
        return ndcpos / -viewpos.z * 0.5 + 0.5;
    }

    vec3 viewtoworld(in vec3 viewpos) {
        return viewpos + cameraPosition;
    }

    float linearizedepth(float depth) {
        return 2.0 * near * far / (far + near - (depth * 2. - 1.) * (far - near));
    }

    #ifdef FRAGMENT
        #ifdef COMPOSITE

            vec3 getndc(in vec2 texcoord, in sampler2D depthsampler) {
                return vec3(texcoord, texture2D(depthsampler, texcoord).r);
            }

        #else

            vec3 getndc() {
                return vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
            }
            
        #endif
    #endif
#endif