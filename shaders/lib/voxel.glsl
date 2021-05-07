const int shadowMapResolution = 4096; // [512 4096]
#define res2D 4096. // [512.0 4096.0]
#define res3D 256.  // [64.0 256.0]
#define resRoot 16. // [8.0 16.0]

vec2 pack_voxelmap(in vec3 block) {
    //Center
    block += res3D / 2.;
    
    //Test if block is inside range
    bool test = all(equal(block, clamp(block, 0., res3D - 1.)));

    //Get xz plane coordinates
    vec2 pixel = mod(block.xz, res3D);

    //Offset by y-cell position
    pixel += mod(floor(block.y / vec2(1., resRoot)), resRoot) * res3D + .5;
    
    return test ? pixel / res2D : vec2(-1.);
}

#ifdef FRAGMENT
    uniform sampler2D shadowcolor0;

    struct Voxel {
        vec4 color;
        vec3 position;
        float distance;
        //vec3 nor;
    };

    Voxel voxeltrace(in vec3 position, in vec3 direction) {
        vec3 s = sign(direction);
        vec3 ray = s / direction;
        vec4 color = vec4(0.);

        uint dist = 0u;
        uint maxdist = int(res3D / 2.);
        for (; color.a < 1. && dist < maxdist; dist++) {
            vec3 f = max(fract(-position * s), 1. - fract(position * s)) * ray;
            vec3 b = vec3(min(f.x, min(f.y, f.z)));
            position += direction * b; // ray trace

            vec2 mappos = pack_voxelmap(floor(position + direction * step(f, b))); // get hit voxel pos in shadowmap
            if (mappos.x < -.5) break; // eliminate non-voxel block

            vec4 hitvoxelcolor = texture2D(shadowcolor0, mappos); // read voxel on the shadowmap
            color += hitvoxelcolor * (1. - color.a); // cumulate hit voxel color with current color
        }
        float normdist = float(dist) / float(maxdist);

        //vec3 normal = s * vec3(equal(position, floor(position)));
        return Voxel(color, position, normdist);
    }
#endif