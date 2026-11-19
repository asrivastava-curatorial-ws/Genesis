#!/usr/bin/env python3
"""Builds the user manual: every page of docs/ (and START_HERE.md) as one
self-contained HTML file for any browser, and a PDF of it when a Chromium
with Playwright is at hand.

    python3 tools/build_manual.py [--no-pdf] [OUT_DIR]   (default: build/manual)

writes OUT_DIR/Oriel-Manual.html (pictures embedded) and, if it
can, OUT_DIR/Oriel-Manual.pdf. Needs pandoc (sudo apt install
pandoc; winget install JohnMacFarlane.Pandoc). Links between pages become
links within the manual; links to files outside docs/ are kept relative to
docs/, where the release puts the manual.
"""
import os, re, shutil, subprocess, sys, tempfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
DOCS = os.path.join(ROOT, "docs")
TITLE = "Oriel: User Manual"

# Reading order: getting going, the program, each section, then reference.
ORDER = [
    "START_HERE", "QUICK_START", "INSTALLATION_LINUX", "INSTALLATION_WINDOWS",
    "USER_MANUAL", "SECTION_GUIDE", "PROJECT_MANAGEMENT", "SCENE_EDITOR", "IMPORTING_MODELS",
    "CAD_AND_PLANS", "ASSET_LIBRARY", "ONLINE_LIBRARY", "MATERIALS", "LANDSCAPE", "ENVIRONMENT",
    "GEOGRAPHIC_CONTEXT", "CAMERAS", "PHOTO_MATCHING", "RENDERING", "PANORAMA",
    "AI_UPSCALING", "MOVIE_AND_ANIMATION", "VR_WALKTHROUGH", "WEB_WALKTHROUGH", "SET_EVENT_PRODUCTION",
    "SHOW_EVENT_OPERATION", "DEPENDENCIES", "PERFORMANCE", "TROUBLESHOOTING",
    "KNOWN_LIMITATIONS", "INVENTORY", "PROJECT_FORMAT", "ARCHITECTURE", "BUILDING_FROM_SOURCE",
    "ASSET_LICENSING",
]
# Kept as files and linked to, not printed in the manual.
LINKED_ONLY = {"THIRD_PARTY_NOTICES", "ORIGINAL_README"}

CSS = """
body { font: 16px/1.55 "Noto Sans", "Segoe UI", system-ui, sans-serif; color: #1d1d1f;
  background: #fff; max-width: 52rem; margin: 0 auto; padding: 1.5rem 1rem 4rem; }
h1 { font-size: 1.7rem; margin-top: 3rem; padding-top: 1rem; border-top: 2px solid #ddd; }
h1.title { border: 0; font-size: 2.1rem; margin-top: 0.5rem; }
h2 { font-size: 1.3rem; margin-top: 2rem; } h3 { font-size: 1.1rem; }
code { font-family: "Noto Sans Mono", Consolas, monospace; font-size: 0.9em;
  background: #f2f2f4; padding: 0.05em 0.3em; border-radius: 3px; }
pre { background: #f2f2f4; padding: 0.8rem 1rem; overflow-x: auto; border-radius: 5px; line-height: 1.4; }
pre code { background: none; padding: 0; }
pre > code.sourceCode { white-space: pre; }
pre > code.sourceCode > span { text-indent: 0; padding-left: 0; display: inline; }
table { border-collapse: collapse; margin: 1rem 0; font-size: 0.95em; }
th, td { border: 1px solid #ccc; padding: 0.35rem 0.6rem; vertical-align: top; text-align: left; }
th { background: #f2f2f4; }
img { max-width: 100%; height: auto; border: 1px solid #ddd; }
blockquote { margin: 1rem 0; padding: 0.5rem 1rem; border-left: 4px solid #e0a000; background: #fff8e6; }
nav#TOC { background: #f7f7f9; padding: 0.5rem 1.5rem; border-radius: 6px; }
nav#TOC > ul > li { margin: 0.25rem 0; }
a { color: #0b5cad; }
@media (prefers-color-scheme: dark) {
  body { background: #1b1b1d; color: #e6e6e6; } a { color: #7db4ff; }
  code, pre, th, nav#TOC { background: #2a2a2e; } th, td, img { border-color: #444; }
  blockquote { background: #332a10; } h1 { border-color: #444; } }
@media print { body { max-width: none; font-size: 10.5pt; } h1 { page-break-before: always; border: 0; }
  h1.title { page-break-before: avoid; } pre, table, img, blockquote { page-break-inside: avoid; }
  h2, h3 { page-break-after: avoid; break-after: avoid; }
  pre, pre code, pre > code.sourceCode { font-size: 7.6pt; white-space: pre-wrap; overflow: visible; }
  nav#TOC { page-break-inside: avoid; } nav#TOC li { margin: 0 !important; font-size: 9.5pt; } }
"""


def anchor(name):
    return "doc-" + name.lower().replace("_", "-")


def rewrite_links(text, here_is_root):
    """Page links become in-manual anchors; other relative links are made
    relative to docs/, where the manual lives."""
    def fix(m):
        label, target = m.group(1), m.group(2)
        if re.match(r"^[a-z]+:", target) or target.startswith("#"):
            return m.group(0)
        path, _, frag = target.partition("#")
        name = os.path.splitext(os.path.basename(path))[0]
        in_docs = (path.startswith("docs/") if here_is_root else "/" not in path)
        if path.endswith(".md") and name in ORDER and (in_docs or name == "START_HERE"):
            return "[%s](#%s)" % (label, frag if frag else anchor(name))
        if path.endswith(".md") and name == "START_HERE":
            return "[%s](#%s)" % (label, anchor(name))
        if here_is_root:
            path = path[5:] if path.startswith("docs/") else "../" + path
        return "[%s](%s%s)" % (label, path, "#" + frag if frag else "")
    return re.sub(r"(?<!!)\[([^\]]+)\]\(([^)\s]+)\)", fix, text)


def pages():
    names = list(ORDER)
    for f in sorted(os.listdir(DOCS)):
        n, ext = os.path.splitext(f)
        if ext == ".md" and n not in names and n not in LINKED_ONLY:
            names.append(n)  # a new page is never left out silently
    return names


def build_markdown():
    parts = []
    for name in pages():
        here_is_root = name == "START_HERE"
        path = os.path.join(ROOT if here_is_root else DOCS, name + ".md")
        if not os.path.exists(path):
            print("  missing page:", name)
            continue
        text = open(path, encoding="utf-8").read()
        text = rewrite_links(text, here_is_root)
        if here_is_root:
            text = text.replace("](docs/", "](")  # pictures: relative to docs/
        parts.append('<div id="%s"></div>\n\n%s' % (anchor(name), text.strip()))
    return "\n\n".join(parts) + "\n"


def main():
    args = [a for a in sys.argv[1:] if a != "--no-pdf"]
    out = os.path.abspath(args[0] if args else os.path.join(ROOT, "build", "manual"))
    os.makedirs(out, exist_ok=True)
    if not shutil.which("pandoc"):
        sys.exit("pandoc is needed: sudo apt install pandoc")
    version = re.search(r'const VERSION := "([^"]+)"', open(os.path.join(ROOT, "app/core/app.gd")).read()).group(1)
    html = os.path.join(out, "Oriel-Manual.html")
    with tempfile.TemporaryDirectory() as tmp:
        md = os.path.join(tmp, "manual.md")
        open(md, "w", encoding="utf-8").write(build_markdown())
        css = os.path.join(tmp, "manual.css")
        open(css, "w").write(CSS)
        subprocess.run(["pandoc", md, "-f", "gfm", "-t", "html5", "-s", "--embed-resources",
                        "--toc", "--toc-depth=1", "--resource-path", DOCS + os.pathsep + ROOT,
                        "-c", css, "--metadata", "title=%s" % TITLE,
                        "--metadata", "subtitle=Version %s" % version, "-o", html], check=True)
    print("Wrote %s (%.1f MB)" % (html, os.path.getsize(html) / 1e6))
    pdf = os.path.join(out, "Oriel-Manual.pdf")
    if "--no-pdf" in sys.argv:
        return
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("No Playwright, so no PDF (pip install playwright; playwright install chromium)")
        return
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.emulate_media(media="print", color_scheme="light")
        page.goto("file://" + html)
        page.pdf(path=pdf, format="A4", print_background=True, display_header_footer=True,
                 header_template="<span></span>",
                 footer_template='<div style="font-size:8px;width:100%%;text-align:center;color:#777">'
                                 'Oriel %s &middot; <span class="pageNumber"></span> / '
                                 '<span class="totalPages"></span></div>' % version,
                 margin={"top": "16mm", "bottom": "16mm", "left": "15mm", "right": "15mm"})
        browser.close()
    print("Wrote %s (%.1f MB)" % (pdf, os.path.getsize(pdf) / 1e6))


if __name__ == "__main__":
    main()
