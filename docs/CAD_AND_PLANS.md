# Plans and CAD

The PLANS section of the Genesis panel.

- **Floor plans** from an image or a PDF page, laid on the ground. *Set its scale*: click two points whose distance you know and type it. White paper can be made clear.
- **CAD drawings**: DXF (read by Genesis itself: lines, polylines and arcs, circles, ellipses, splines, 3D faces, text, blocks with nesting), a PDF plotted from CAD (read as vectors, one layer per pen), or DWG through the free ODA File Converter. They come in at true size in their own layers and colours. Tick layers to show them, or to raise their lines as walls.
- **Measuring** snaps to a drawing's corners and line ends.

Plans and drawings are copied into the project's `data/plans` and `data/cad`, so the project travels with them.

Needs: Poppler (or MuPDF) for PDF pages, ODA File Converter for DWG. See [DEPENDENCIES.md](DEPENDENCIES.md).

Tested in this release: DXF import (end-to-end test). PDF and DWG were not tested here (no Poppler sample or ODA converter).
