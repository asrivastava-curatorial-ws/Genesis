#!/usr/bin/env python3
"""Makes the noise the volumetric clouds are carved from:

    python3 tools/make_cloud_noise.py   ->  addons/genesis/core/gn_cloud_noise.bin

Two blocks of noise that tile in every direction:
  shape  96 x 96 x 96, three bytes a cell: soft billows (Perlin), and two
         scales of cells (Worley) that round them into heaps;
  detail 32 x 32 x 32, one byte a cell: small cells that fray the edges.
The file is: "ORCN", four 32-bit sizes (shape side, shape channels, detail
side, detail channels), then the bytes, zlib-compressed. Needs numpy.
Run once; the result is part of the program (it never changes)."""
import os
import struct
import zlib

import numpy as np

RNG = np.random.default_rng(20261110)


def perlin(n, period):
    """Tileable gradient noise, n cells a side, `period` lattice cells across."""
    g = RNG.normal(size=(period, period, period, 3))
    g /= np.linalg.norm(g, axis=3, keepdims=True)
    t = (np.arange(n) + 0.5) / n * period
    i0 = np.floor(t).astype(int) % period
    i1 = (i0 + 1) % period
    f = t - np.floor(t)
    fade = f * f * f * (f * (f * 6 - 15) + 10)
    out = np.zeros((n, n, n))
    fx, fy, fz = np.meshgrid(f, f, f, indexing="ij")
    ux, uy, uz = np.meshgrid(fade, fade, fade, indexing="ij")
    for dx in (0, 1):
        ix = i1 if dx else i0
        wx = ux if dx else 1 - ux
        for dy in (0, 1):
            iy = i1 if dy else i0
            wy = uy if dy else 1 - uy
            for dz in (0, 1):
                iz = i1 if dz else i0
                wz = uz if dz else 1 - uz
                grad = g[np.ix_(ix, iy, iz)]
                dot = grad[..., 0] * (fx - dx) + grad[..., 1] * (fy - dy) + grad[..., 2] * (fz - dz)
                out += wx * wy * wz * dot
    return out


def worley(n, cells):
    """Tileable cell noise: 1 at a cell's heart, 0 at its edge."""
    pts = RNG.random(size=(cells, cells, cells, 3))
    t = (np.arange(n) + 0.5) / n * cells
    px, py, pz = np.meshgrid(t, t, t, indexing="ij")
    cx, cy, cz = np.floor(px).astype(int), np.floor(py).astype(int), np.floor(pz).astype(int)
    best = np.full((n, n, n), 9.0)
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1):
            for dz in (-1, 0, 1):
                ix, iy, iz = cx + dx, cy + dy, cz + dz
                p = pts[ix % cells, iy % cells, iz % cells]
                d = np.sqrt((ix + p[..., 0] - px) ** 2 + (iy + p[..., 1] - py) ** 2 + (iz + p[..., 2] - pz) ** 2)
                best = np.minimum(best, d)
    return np.clip(1.0 - best, 0.0, 1.0)


def fbm(fn, n, first, octaves):
    total, amp, norm = np.zeros((n, n, n)), 1.0, 0.0
    for o in range(octaves):
        total += amp * fn(n, first * 2 ** o)
        norm += amp
        amp *= 0.5
    return total / norm


def to_bytes(a):
    return np.clip(np.round(a * 255.0), 0, 255).astype(np.uint8)


def main():
    n = 96
    billow = fbm(perlin, n, 3, 4)
    billow = (billow - billow.min()) / (billow.max() - billow.min())
    heaps = fbm(worley, n, 4, 3)
    fine = fbm(worley, n, 8, 3)
    shape = np.stack([billow, heaps, fine], axis=3)             # x, y, z, channel
    m = 32
    detail = fbm(worley, m, 3, 3)[..., None]
    # Godot's 3D textures are a pile of pictures: depth, then rows, then columns.
    raw = to_bytes(np.transpose(shape, (2, 1, 0, 3))).tobytes() + to_bytes(np.transpose(detail, (2, 1, 0, 3))).tobytes()
    here = os.path.dirname(os.path.abspath(__file__))
    dest = os.path.join(here, "..", "addons", "genesis", "core", "gn_cloud_noise.bin")
    with open(dest, "wb") as f:
        f.write(b"ORCN" + struct.pack("<4I", n, 3, m, 1) + zlib.compress(raw, 9))
    print("%s: %d bytes (%d before packing); billow mean %.3f, heaps mean %.3f, fine mean %.3f, detail mean %.3f" % (
        os.path.normpath(dest), os.path.getsize(dest), len(raw), billow.mean(), heaps.mean(), fine.mean(), detail.mean()))


if __name__ == "__main__":
    main()
