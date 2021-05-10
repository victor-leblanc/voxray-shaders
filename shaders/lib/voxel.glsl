const int shadowMapResolution = 4096; // [512 4096 32768]
#define VOXELMAP_RESOLUTION_3D 256.0 // [64.0 256.0 1024.0]
#define VOXELMAP_ROOT 16.0 // [8.0 16.0 32.0]
#define TRACE_DISTANCE_LIMIT 2.0 // [1.0 2.0 4.0]

#ifndef COMMON_LIB_VOXEL
#define COMMON_LIB_VOXEL

    vec2 packvoxelposition(in vec3 block) {
        block += VOXELMAP_RESOLUTION_3D / 2.; // block center
        if (all(equal(block, clamp(block, 0., VOXELMAP_RESOLUTION_3D - 1.)))) { // test if block is inside range
            vec2 pixel = mod(block.xz, VOXELMAP_RESOLUTION_3D); // get xz plane coordinates
            pixel += mod(floor(block.y / vec2(1., VOXELMAP_ROOT)), VOXELMAP_ROOT) * VOXELMAP_RESOLUTION_3D + .5; // offset by y-cell position
            return pixel / float(shadowMapResolution);
        }
        return vec2(-1.);
    }

    #ifdef FRAGMENT

        #include "pack.glsl"

        struct VoxelProperty {
            vec4 color;
            uint shape; // see block.properties
            uint light; // see block.properties
        };

        vec3 packvoxelproperty(in uint entityid, in vec4 color) {
            // retrieve properties from id and color
            VoxelProperty property;
            property.color = color;
            property.shape = (entityid / 10) % 10;
            property.light = entityid % 10;

            // pack everything into a vec3
            uvec4 rangedcolor4b = uvec4(property.color * 15.); // to range 0-15 (4 bits)
            uvec3 packedvp;
            packedvp[0] = pack2x4in8(rangedcolor4b.r, rangedcolor4b.g); // pack 4 bits R and G channels into one 8 bit channel
            packedvp[1] = pack2x4in8(rangedcolor4b.b, rangedcolor4b.a); // pack 4 bits B and A channels into one 8 bit channel
            packedvp[2] = pack2x4in8(property.shape, property.light);
            return vec3(packedvp) / 255.; // to range 0-1
        }

        VoxelProperty unpackvoxelproperty(in vec4 voxmapcolor) {
            // unpack everything
            uvec3 packedvp = uvec3(voxmapcolor.rgb * 255.); // to range 0-255 (8 bits)
            uvec4 rangedcolor4b;
            rangedcolor4b.rg = unpack2x4from8(packedvp[0]); // unpack 4 bits R and G channels from the first 8 bit channel
            rangedcolor4b.ba = unpack2x4from8(packedvp[1]); // unpack 4 bits B and A channels from the second 8 bit channel
            uvec2 unpackedattrib = unpack2x4from8(packedvp[2]);

            // reconstruct the properties
            return VoxelProperty(
                vec4(rangedcolor4b) / 15., // to range 0-1
                unpackedattrib[0],
                unpackedattrib[1]
            );
        }

        #ifdef COMPOSITE

            uniform sampler2D shadowcolor0;

            struct Voxel {
                VoxelProperty property;
                vec3 position;
                float distance;
                vec3 normal;
            };

            Voxel voxeltrace(in vec3 position, in vec3 direction) {
                vec3 s = sign(direction);
                vec3 ray = s / direction;
                VoxelProperty property = VoxelProperty(vec4(0.), 0, 0);

                uint dist = 0u;
                uint maxdist = uint(VOXELMAP_RESOLUTION_3D / TRACE_DISTANCE_LIMIT);
                for (; property.color.a < 1. && dist < maxdist; dist++) {
                    vec3 f = max(fract(-position * s), 1. - fract(position * s)) * ray;
                    vec3 b = vec3(min(f.x, min(f.y, f.z)));
                    position += direction * b; // ray trace

                    vec2 mappos = packvoxelposition(floor(position + direction * step(f, b))); // get hit voxel pos in shadowmap
                    if (mappos.x < -.5) break; // eliminate non-voxel block

                    vec4 hitvoxel = texture2D(shadowcolor0, mappos); // read voxel on the shadowmap
                    VoxelProperty hitproperty = unpackvoxelproperty(hitvoxel);
                    //if (hitproperty.shape == 1) {
                        property.color += hitproperty.color * (1. - property.color.a);
                        property.shape = hitproperty.shape;
                        property.light = hitproperty.light;
                    //}
                }

                float normdist = float(dist) / float(maxdist);
                vec3 normal = s * vec3(equal(position, floor(position)));
                return Voxel(property, position, normdist, normal);
            }

        #endif
    #endif
#endif