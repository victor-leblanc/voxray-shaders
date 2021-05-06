#ifndef COMMON_LIB_STD
#define COMMON_LIB_STD

    /* vector sum */
    float sumvec2(in vec2 vec) {
        return vec.x + vec.y;
    }

    float sumvec3(in vec3 vec) {
        return vec.x + vec.y + vec.z;
    }

    float sumvec4(in vec4 vec) {
        return vec.x + vec.y + vec.z + vec.w;
    }

    /* vector average */
    float averagevec2(in vec2 vec) {
        return sumvec2(vec) / 2.;
    }

    float averagevec3(in vec3 vec) {
        return sumvec3(vec) / 3.;
    }

    float averagevec4(in vec4 vec) {
        return sumvec4(vec) / 4.;
    }

    /* vector diff */
    vec2 diffvec2(in vec2 v1, in vec2 v2) {
        return vec2(abs(v1.x - v2.x), abs(v1.y - v2.y));
    }

    vec3 diffvec3(in vec3 v1, in vec3 v2) {
        return vec3(abs(v1.x - v2.x), abs(v1.y - v2.y), abs(v1.z - v2.z));
    }

    vec4 diffvec4(in vec4 v1, in vec4 v2) {
        return vec4(abs(v1.x - v2.x), abs(v1.y - v2.y), abs(v1.z - v2.z), abs(v1.w - v2.w));
    }

    /* comparison condition */
    bool eqfloat(in float f1, in float f2, in const float margin = 1e-5) {
        return abs(f1 - f2) < margin;
    }

    bool eqvec2(in vec2 v1, in vec2 v2, in const float margin = 1e-5) {
        return sumvec2(diffvec2(v1, v2)) < margin;
    }

    bool eqvec3(in vec3 v1, in vec3 v2, in const float margin = 1e-5) {
        return sumvec3(diffvec3(v1, v2)) < margin;
    }

    bool eqvec4(in vec4 v1, in vec4 v2, in const float margin = 1e-5) {
        return sumvec4(diffvec4(v1, v2)) < margin;
    }

    /* matrix composition */
    mat4 translationtomat(in vec3 translation) {
        return mat4(
            1., 0., 0., 0.,
            0., 1., 0., 0.,
            0., 0., 1., 0.,
            translation.x, translation.y, translation.z, 1.
        );
    }

    vec3 translationfrommat(in mat4 mat) {
        return mat[3].xyz;
    }

    mat4 scaletomat(in vec3 scale) {
        return mat4(
            scale.x, 0., 0., 0.,
            0., scale.y, 0., 0.,
            0., 0., scale.z, 0.,
            0., 0., 0., 1.
        );
    }

    vec3 scalefrommat(in mat4 mat) {
        return vec3(mat[0].x, mat[1].y, mat[2].z);
    }

#endif