#ifndef COMMON_LIB_PACK
#define COMMON_LIB_PACK

    uint pack2x4in8(in uint ui4a, in uint ui4b) {
        return (ui4a << 4) | ui4b;
    }

    uvec2 unpack2x4from8(in uint ui8) {
        return uvec2(ui8 >> 4, ui8 & 0xf);
    }

#endif