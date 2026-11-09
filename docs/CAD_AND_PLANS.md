# Plans and CAD

The PLANS section of the Oriel panel.

- **Floor plans** from an image or a PDF page, laid on the ground. *Set its scale*: click two points whose distance you know and type it. White paper can be made clear.
- **CAD drawings**: DXF (read by Oriel itself: lines, polylines and arcs, circles, ellipses, splines, 3D faces, text, blocks with nesting), a PDF plotted from CAD (read as vectors, one layer per pen), or DWG through the free ODA File Converter. They come in at true size in their own layers and colours. Tick layers to show them, or to raise their lines as walls.
- **Measuring** snaps to a drawing's corners and line ends.

Plans and drawings are copied into the project's `data/plans` and `data/cad`, so the project travels with them.

Needs: Poppler (or MuPDF) for PDF pages, ODA File Converter for DWG. See [DEPENDENCIES.md](DEPENDENCIES.md).

Tested in this release: DXF import, a CAD-plotted PDF read as lines at scale, and a PDF floor plan as a picture through Poppler at scale (automated and in the end-to-end test). DWG was not tested: the ODA File Converter is not open source and could not be installed on the build machine.
