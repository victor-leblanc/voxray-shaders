#version 460 compatibility

attribute vec4 at_tangent;
attribute float mc_Entity;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

out vec3 normal;
out vec3 diffuse;
out vec2 texcoord;
out vec2 lmcoord;
out mat3 tbn;

void main()
{
    gl_Position = ftransform();

    normal = gl_Normal;
    vec3 tangent = normalize(at_tangent.xyz);
    vec3 binormal = cross(tangent, normal) * sign(at_tangent.w);
    tbn = mat3(tangent, binormal, normal);
    
    if (mc_Entity == 1.) {
        normal = vec3(0., 1., 0.);
    }

    float light = .8 - .25 * abs(normal.x * .9 + normal.z * .3) + normal.y * .2;
    diffuse = gl_Color.rgb * light;
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).st;
}
