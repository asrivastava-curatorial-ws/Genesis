# Panoramas and virtual tours

RENDER > 360° panorama: from a saved camera's position, six views are stitched into one equirectangular image (2:1), the format every 360 viewer reads. Stereo (top-bottom) is available for headsets. The look's grading applies; depth of field, two-point perspective and vignette are left out.

**Virtual tour**: a panorama from every saved camera in one HTML file; rings mark the other views. Served over https it offers *Enter VR*.

With *Eevee* or *Cycles* chosen on the Render page, panoramas and the virtual tour are rendered by them: Cycles with its panoramic camera, Eevee from six views that Oriel stitches. A stereo 360° always uses Cycles. See [RENDERING.md](RENDERING.md).
