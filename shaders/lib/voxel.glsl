/*
// LOW
const int shadowMapResolution = 512;
#define res2D 512.
#define res3D 64.  //pow(res2D, 2. / 3.)
#define resRoot 8. //sqrt(res3D) or pow(res2D, 1. / 3.)
*/

// HIGH
const int shadowMapResolution = 4096;
#define res2D 4096.
#define res3D 256.  //pow(res2D, 2. / 3.)
#define resRoot 16. //sqrt(res3D) or pow(res2D, 1. / 3.)


vec2 pack_voxelmap(in vec3 block)
{
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
