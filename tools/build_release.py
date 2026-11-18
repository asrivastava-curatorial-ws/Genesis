#!/usr/bin/env python3
"""Assembles the Genesis Community release:

    python3 tools/build_release.py [--demos DIR] [--skip-build] [--platforms linux,windows]

1. builds Linux and Windows with tools/build_standalone.sh (Linux is smoke-tested;
   --platforms linux makes a Linux-only release: no Windows program, one zip),
2. lays out Genesis-Community-<version>/ as below,
3. writes checksums/SHA256SUMS and zips it to release/Genesis-Community-<version>.zip,
   and to -linux-x86_64.zip and -windows-x86_64.zip (each without the other
   platform's program; both unpack into the same folder).

    START_HERE.md README.md CHANGELOG.md LICENSE THIRD_PARTY_NOTICES.md
    applications/linux-x86_64/    Genesis, Genesis.pck, Genesis.sh, genesis.png
    applications/windows-x86_64/  Genesis.exe, Genesis.pck, Genesis.bat, Genesis.ps1
    source/                       the source at this commit (git archive)
    demos/architecture/ demos/event-production/   (from --demos, made by
                                  Genesis -- --make-demos DIR)
    docs/ reports/ tests/ tools/  (docs/ also gets Genesis-Community-Manual.html
                                  and .pdf from tools/build_manual.py)
    checksums/SHA256SUMS

Standard library only. Godot is found from $GODOT or tests/local.env.
"""
import hashlib, os, re, shutil, subprocess, sys, zipfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def version():
    text = open(os.path.join(ROOT, "app/core/app.gd")).read()
    return re.search(r'const VERSION := "([^"]+)"', text).group(1)


def godot():
    g = os.environ.get("GODOT")
    env = os.path.join(ROOT, "tests/local.env")
    if not g and os.path.exists(env):
        for line in open(env):
            if line.startswith("GODOT="):
                g = line.strip().split("=", 1)[1]
    return g or "godot"


def run(cmd, **kw):
    print(">", " ".join(cmd))
    subprocess.run(cmd, check=True, **kw)


def icon_png(dest):
    """The SVG icon drawn at 256 px by Godot itself."""
    script = os.path.join(ROOT, "build", "icon.gd")
    os.makedirs(os.path.dirname(script), exist_ok=True)
    with open(script, "w") as f:
        f.write('extends SceneTree\nfunc _initialize() -> void:\n\tvar img := Image.new()\n'
                '\timg.load_svg_from_buffer(FileAccess.get_file_as_bytes("%s"), 2.0)\n'
                '\timg.save_png("%s")\n\tquit()\n' % (os.path.join(ROOT, "app/assets/icon.svg"), dest))
    run([godot(), "--headless", "-s", script], cwd=os.path.join(ROOT, "build"), stdout=subprocess.DEVNULL)


def main():
    args = sys.argv[1:]
    demos = args[args.index("--demos") + 1] if "--demos" in args else ""
    platforms = args[args.index("--platforms") + 1].split(",") if "--platforms" in args else ["linux", "windows"]
    ver = version()
    name = "Genesis-Community-%s" % ver
    out_root = os.path.join(ROOT, "release")
    os.makedirs(out_root, exist_ok=True)
    # Not part of the project: Godot's editor leaves the folder alone.
    open(os.path.join(out_root, ".gdignore"), "w").close()
    out = os.path.join(out_root, name)
    if "--skip-build" not in args:
        run(["bash", os.path.join(ROOT, "tools/build_standalone.sh")] + platforms, env=dict(os.environ, GODOT=godot()))
    shutil.rmtree(out, ignore_errors=True)
    os.makedirs(out)
    for f in ["START_HERE.md", "README.md", "CHANGELOG.md", "LICENSE", "THIRD_PARTY_NOTICES.md", "DEVELOPMENT_STATUS.md"]:
        shutil.copy(os.path.join(ROOT, f), out)
    # Applications.
    lin = os.path.join(out, "applications/linux-x86_64")
    win = os.path.join(out, "applications/windows-x86_64")
    if "linux" in platforms:
        os.makedirs(lin)
        shutil.copy(os.path.join(ROOT, "build/linux/Genesis.x86_64"), os.path.join(lin, "Genesis.x86_64"))
        shutil.copy(os.path.join(ROOT, "build/linux/Genesis.pck"), lin)
        shutil.copy(os.path.join(ROOT, "tools/launchers/Genesis.sh"), lin)
        os.chmod(os.path.join(lin, "Genesis.x86_64"), 0o755)
        os.chmod(os.path.join(lin, "Genesis.sh"), 0o755)
        icon_png(os.path.join(lin, "genesis.png"))
        shutil.copy(os.path.join(ROOT, "LICENSE"), lin)
    if "windows" in platforms:
        os.makedirs(win)
        shutil.copy(os.path.join(ROOT, "build/windows/Genesis.exe"), win)
        shutil.copy(os.path.join(ROOT, "build/windows/Genesis.pck"), win)
        for f in ["Genesis.bat", "Genesis.ps1"]:
            shutil.copy(os.path.join(ROOT, "tools/launchers", f), win)
        shutil.copy(os.path.join(ROOT, "LICENSE"), win)
    # Source, exactly as committed.
    src = os.path.join(out, "source")
    os.makedirs(src)
    archive = subprocess.run(["git", "archive", "HEAD"], cwd=ROOT, check=True, capture_output=True).stdout
    subprocess.run(["tar", "-x", "-C", src], input=archive, check=True)
    # Documents, reports, tests, tools at the top for convenience.
    for d in ["docs", "reports", "tests", "tools"]:
        shutil.copytree(os.path.join(ROOT, d), os.path.join(out, d), ignore=shutil.ignore_patterns("local.env", "__pycache__"))
    # The manual in one file (HTML always; PDF when Playwright is installed).
    run([sys.executable, os.path.join(ROOT, "tools/build_manual.py"), os.path.join(out, "docs")])
    # Demonstration projects.
    if demos:
        for src_name, dst_name in [("Architecture demo", "architecture"), ("Event production demo", "event-production")]:
            p = os.path.join(demos, src_name)
            if os.path.isdir(p):
                shutil.copytree(p, os.path.join(out, "demos", dst_name), ignore=shutil.ignore_patterns(".genesis", "backups"))
    # Checksums of every file.
    sums = []
    for base, _, files in os.walk(out):
        for f in sorted(files):
            p = os.path.join(base, f)
            h = hashlib.sha256()
            with open(p, "rb") as fh:
                for block in iter(lambda: fh.read(1 << 20), b""):
                    h.update(block)
            sums.append("%s  %s" % (h.hexdigest(), os.path.relpath(p, out)))
    sums.sort(key=lambda s: s[66:])
    os.makedirs(os.path.join(out, "checksums"))
    with open(os.path.join(out, "checksums/SHA256SUMS"), "w") as f:
        f.write("\n".join(sums) + "\n")
    # The whole release, and one zip per platform: the same folder without the
    # other platform's program (each under the 500 MB many upload limits allow).
    # Both unpack into the same folder, so together they make the whole release.
    for old in [name + ".zip", name + "-linux-x86_64.zip", name + "-windows-x86_64.zip"]:
        if os.path.exists(os.path.join(out_root, old)):
            os.remove(os.path.join(out_root, old))
    if len(platforms) == 1:
        # One platform: one zip, named for it.
        write_zip(out, name, os.path.join(out_root, "%s-%s-x86_64.zip" % (name, platforms[0])), sums, None)
        return
    write_zip(out, name, os.path.join(out_root, name + ".zip"), sums, None)
    write_zip(out, name, os.path.join(out_root, name + "-linux-x86_64.zip"), sums, "applications/windows-x86_64/")
    write_zip(out, name, os.path.join(out_root, name + "-windows-x86_64.zip"), sums, "applications/linux-x86_64/")


def write_zip(out, name, zpath, sums, leave_out):
    """Zips the release folder `out` as `name/...`, keeping the executable bits;
    files under `leave_out` are left out, and so are their checksums."""
    if os.path.exists(zpath):
        os.remove(zpath)
    with zipfile.ZipFile(zpath, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for base, dirs, files in os.walk(out):
            rel_base = os.path.relpath(base, out)
            if leave_out and (rel_base + "/").startswith(leave_out):
                continue
            if not files and not dirs:
                # Empty folders (a demo's assets/, backups/) are kept as folders.
                z.write(base, os.path.join(name, rel_base))
            for f in sorted(files):
                p = os.path.join(base, f)
                rel = os.path.relpath(p, out)
                if leave_out and rel == "checksums/SHA256SUMS":
                    kept = [s for s in sums if not s[66:].startswith(leave_out)]
                    info = zipfile.ZipInfo.from_file(p, os.path.join(name, rel))
                    z.writestr(info, "\n".join(kept) + "\n", zipfile.ZIP_DEFLATED)
                    continue
                # write() keeps the file's permissions (the executables stay executable).
                z.write(p, os.path.join(name, rel))
    print("Wrote %s (%.0f MB)" % (zpath, os.path.getsize(zpath) / 1e6))


if __name__ == "__main__":
    main()
