An Oriel web walkthrough
========================

This folder is the whole walkthrough: a page (index.html), its viewer (app/)
and the scene (scene/). Nothing is fetched from anywhere else.

To look at it on this computer
    python3 serve.py
then open http://localhost:8080 in a browser. (Opening index.html by itself
does not work: browsers only let such a page read its files from a server.)

On a phone or a headset on the same network
    python3 serve.py
and open http://<this computer's address>:8080 (serve.py prints it).
VR needs a secure address. Either of:
    adb reverse tcp:8080 tcp:8080      (USB cable; then http://localhost:8080 in the headset)
    openssl req -x509 -newkey rsa:2048 -nodes -days 365 -subj "/CN=oriel" -keyout key.pem -out cert.pem
    python3 serve.py --https cert.pem key.pem
                                        (then https://<address>:8443, accepting the certificate once)

To put it on the web
    Copy the folder as it is to any web server or static host (GitHub Pages,
    GitLab Pages, an S3 bucket, nginx, Apache). It needs no server-side
    program. Served over https, the VR button works in a headset's browser.
    To show it inside another page:
        <iframe src="https://example.org/walkthrough/?embed" allow="xr-spatial-tracking; fullscreen" style="width:100%;height:70vh;border:0"></iframe>

Addresses
    .../#view=Name            starts at the view of that name
    .../?q=low  or  ?q=high   lighter or sharper drawing than the device's own choice
    .../?autostart            no cover page

Made with Oriel (MIT). The viewer includes three.js and three-mesh-bvh (MIT)
and the JetBrains Mono typeface (SIL Open Font License 1.1): see app/LICENSES.txt.
The models, pictures and sounds of the scene keep their own licences.
