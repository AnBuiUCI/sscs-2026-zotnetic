"""Convierte un volcado xwd a PNG.

No hay ImageMagick ni netpbm en la maquina, asi que se lee el formato a mano.
XWD version 7: cabecera de 25 enteros de 32 bits en big-endian, luego el nombre
de la ventana, luego el mapa de color y por ultimo los pixeles.
"""
import struct
import sys

from PIL import Image

CAMPOS = ("header_size file_version pixmap_format pixmap_depth pixmap_width "
          "pixmap_height xoffset byte_order bitmap_unit bitmap_bit_order "
          "bitmap_pad bits_per_pixel bytes_per_line visual_class red_mask "
          "green_mask blue_mask bits_per_rgb colormap_entries ncolors "
          "window_width window_height window_x window_y window_bdrwidth").split()


def leer(ruta):
    d = open(ruta, "rb").read()
    h = dict(zip(CAMPOS, struct.unpack(">25I", d[:100])))
    if h["file_version"] != 7:
        raise SystemExit(f"version xwd {h['file_version']}, esperaba 7")
    ini = h["header_size"] + h["ncolors"] * 12
    w, alto, bpl, bpp = (h["pixmap_width"], h["pixmap_height"],
                         h["bytes_per_line"], h["bits_per_pixel"])
    if bpp not in (24, 32):
        raise SystemExit(f"{bpp} bits por pixel, solo se manejan 24 y 32")
    px = d[ini:ini + bpl * alto]
    img = Image.frombytes("RGBX" if bpp == 32 else "RGB", (w, alto), px,
                          "raw", "BGRX" if bpp == 32 else "BGR", bpl, 1)
    return img.convert("RGB")


if __name__ == "__main__":
    im = leer(sys.argv[1])
    im.save(sys.argv[2])
    print(f"  {sys.argv[2]}  {im.size[0]}x{im.size[1]}")
