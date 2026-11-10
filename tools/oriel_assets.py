#!/usr/bin/env python3
"""Download Oriel's starter pack of free assets into your library, from a terminal.

    python3 oriel_assets.py                      the standard pack (about 700 MB)
    python3 oriel_assets.py --size small         about 150 MB; or --size large, about 2.5 GB
    python3 oriel_assets.py --only skies,materials
    python3 oriel_assets.py --list               show what would be downloaded, download nothing
    python3 oriel_assets.py --dest /some/folder  another library folder

From the AppImage, without Python on the computer:
    ./Oriel-<version>-x86_64.AppImage --get-assets --size small

What it gets: skies, materials and models from Poly Haven (CC0, powered by
Poly Haven) and ambientCG (CC0), chosen in addons/genesis/data/starter_pack.json:
favourites first, then each source's most downloaded in the useful categories.
BlendKit's assets need its Client and a login, so they are downloaded inside
Oriel (Online page), not here.

Safe to stop (Ctrl+C) and run again: every file is written as .part and only
kept once whole and matching the checksum the source publishes; a stopped file
carries on where it stopped; a server that says "too many requests" is waited
for as long as it asks; nothing already here is downloaded again. What was
downloaded is recorded in <library>/online/manifest.json (written atomically,
the previous one kept as manifest.json.bak). Oriel turns the downloaded
materials and models into library items the next time its Online page opens.

Standard library only; Python 3.8 or newer; Linux, Windows and macOS.
Part of Oriel, MIT licence.
"""
import argparse
import email.utils
import hashlib
import json
import os
import shutil
import sys
import time
import urllib.error
import urllib.request
import zipfile

UA = "Oriel/1.0 asset script (open-source visualisation; +https://github.com/Utopian-Academy/Genesis)"
PH_API = os.environ.get("ORIEL_POLYHAVEN_API", "https://api.polyhaven.com")
ACG_API = "https://ambientcg.com/api/v3/assets"
ACG_GET = "https://ambientcg.com/get?file=%s_%s-%s.zip"
PH_CATEGORY = {"furniture": "furniture", "seating": "furniture", "table": "furniture", "plants": "plants",
               "nature": "plants", "trees": "trees", "vehicle": "vehicles", "lighting": "lighting",
               "decorative": "props", "props": "props"}


def user_library():
    """The library folder Oriel uses on this computer."""
    if sys.platform.startswith("win"):
        base = os.environ.get("APPDATA", os.path.expanduser("~\\AppData\\Roaming"))
    elif sys.platform == "darwin":
        base = os.path.expanduser("~/Library/Application Support")
    else:
        base = os.environ.get("XDG_DATA_HOME", os.path.expanduser("~/.local/share"))
    return os.path.join(base, "Oriel", "library")


def find_pack():
    here = os.path.dirname(os.path.abspath(__file__))
    for p in (os.path.join(here, "starter_pack.json"),
              os.path.join(here, "..", "addons", "genesis", "data", "starter_pack.json")):
        if os.path.exists(p):
            return json.load(open(p, encoding="utf-8"))
    raise SystemExit("starter_pack.json was not found beside this script")


class Stopped(Exception):
    pass


def say(text, end="\n"):
    sys.stdout.write("\r\033[K" + text + end if sys.stdout.isatty() else text + "\n")
    sys.stdout.flush()


def request(url, start=0):
    headers = {"User-Agent": UA}
    if start:
        headers["Range"] = "bytes=%d-" % start
    return urllib.request.urlopen(urllib.request.Request(url, headers=headers), timeout=60)


def wait_for(err, attempt):
    """Seconds to wait after an HTTP error, or None to give up."""
    if isinstance(err, urllib.error.HTTPError):
        if err.code in (429, 503):
            ra = err.headers.get("Retry-After", "60")
            try:
                return max(1, min(3600, int(ra)))
            except ValueError:
                try:
                    return max(1, min(3600, int(email.utils.parsedate_to_datetime(ra).timestamp() - time.time())))
                except Exception:
                    return 60
        if err.code in (401, 403, 404, 410):
            return None
    return min(2 ** attempt, 60) if attempt <= 6 else None


def get_json(url, tries=40):
    for attempt in range(1, tries + 1):
        try:
            with request(url) as r:
                return json.loads(r.read().decode("utf-8"))
        except (urllib.error.URLError, OSError, ValueError) as e:
            w = wait_for(e, attempt)
            if w is None or attempt >= tries:
                raise
            say("  %s; trying again in %d s" % (e, w))
            time.sleep(w)
    raise RuntimeError("no answer from %s" % url)


def verify(path, md5="", size=0):
    if not os.path.exists(path):
        return False
    if size and os.path.getsize(path) != int(size):
        return False
    if md5:
        h = hashlib.md5()
        with open(path, "rb") as f:
            for block in iter(lambda: f.read(1 << 20), b""):
                h.update(block)
        return h.hexdigest() == md5.lower()
    return True


def fetch(url, dest, md5="", size=0, label=""):
    """Downloads url to dest through dest.part; resumes; checks; never keeps a bad file."""
    if verify(dest, md5, size):
        return "kept"
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    part = dest + ".part"
    restarted = False
    attempt = 0
    while True:
        have = os.path.getsize(part) if os.path.exists(part) else 0
        try:
            with request(url, have) as r:
                status = getattr(r, "status", 200)
                mode = "ab" if (have and status == 206) else "wb"
                got = have if mode == "ab" else 0
                total = r.headers.get("Content-Length")
                total = int(total) + got if total else 0
                with open(part, mode) as f:
                    while True:
                        block = r.read(1 << 20)
                        if not block:
                            break
                        f.write(block)
                        got += len(block)
                        if total:
                            say("  %s %d%% of %.1f MB" % (label, 100 * got // total, total / 1e6), end="")
        except KeyboardInterrupt:
            raise Stopped()
        except urllib.error.HTTPError as e:
            if e.code == 416 and have:
                pass        # already whole; the checksum decides
            else:
                attempt += 1
                w = wait_for(e, attempt)
                if w is None:
                    raise
                say("  the server's limit was reached; carrying on in %d s" % w if e.code in (429, 503)
                    else "  %s; trying again in %d s" % (e, w))
                time.sleep(w)
                continue
        except (urllib.error.URLError, OSError) as e:
            attempt += 1
            w = wait_for(e, attempt)
            if w is None or (attempt >= 3 and not have):
                raise
            say("  %s; trying again in %d s" % (e, w))
            time.sleep(w)
            continue
        if verify(part, md5, size):
            os.replace(part, dest)
            return "downloaded"
        os.remove(part)
        if restarted:
            raise RuntimeError("%s does not match its checksum" % os.path.basename(dest))
        restarted = True


class Manifest:
    def __init__(self, library):
        self.dir = os.path.join(library, "online")
        self.path = os.path.join(self.dir, "manifest.json")
        try:
            self.data = json.load(open(self.path, encoding="utf-8"))
        except Exception:
            self.data = {"schema": 1, "assets": {}}
        self.data.setdefault("assets", {})

    def done(self, source, id_):
        e = self.data["assets"].get("%s:%s" % (source, id_), {})
        return e.get("state") in ("complete", "downloaded")

    def put(self, entry):
        self.data["assets"]["%s:%s" % (entry["source"], entry["id"])] = entry
        os.makedirs(self.dir, exist_ok=True)
        tmp = self.path + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(self.data, f, indent=2)
        if os.path.exists(self.path):
            shutil.copyfile(self.path, self.path + ".bak")
        os.replace(tmp, self.path)


def licence(path, item):
    with open(path, "w", encoding="utf-8") as f:
        json.dump({"license": "CC0-1.0", "author": item.get("author", ""), "source": item["page"],
                   "attribution": ""}, f, indent=2)


def pick(tree, res, formats):
    if not isinstance(tree, dict):
        return None
    for r in (res, "2k", "1k", "4k", "8k"):
        for fmt in formats:
            f = tree.get(r, {}).get(fmt) if isinstance(tree.get(r), dict) else None
            if isinstance(f, dict) and "url" in f:
                return f
    return None


def ph_plan(group, size):
    t = {"skies": "hdris", "materials": "textures", "models": "models"}[group["kind"]]
    listing = get_json("%s/assets?t=%s" % (PH_API, t), tries=3)
    count = int(group.get("count", {}).get(size, 0))
    out, seen = [], set()
    for id_ in group.get("prefer", []):
        if id_ in listing and len(out) < count:
            out.append(id_)
            seen.add(id_)
    cats = set(group.get("categories", []))
    for id_, a in sorted(listing.items(), key=lambda kv: -int(kv[1].get("download_count", 0))):
        if len(out) >= count:
            break
        if id_ in seen or (cats and not cats & set(a.get("categories", []))):
            continue
        out.append(id_)
    return [{"source": "polyhaven", "id": i, "kind": group["kind"], "name": listing[i].get("name", i),
             "author": ", ".join(listing[i].get("authors", {}).keys()), "categories": listing[i].get("categories", []),
             "dimensions": listing[i].get("dimensions", []), "page": "https://polyhaven.com/a/" + i} for i in out]


def acg_plan(group, size):
    count = int(group.get("count", {}).get(size, 0))
    ids = list(group.get("prefer", []))[:count]
    if len(ids) < count:
        try:
            data = get_json("%s?type=material&limit=%d&sort=popular&include=title" % (ACG_API, count * 2), tries=2)
            for a in (data.get("assets") or data.get("foundAssets") or []) if isinstance(data, dict) else []:
                if len(ids) >= count:
                    break
                if a.get("id") and a["id"] not in ids:
                    ids.append(a["id"])
        except Exception as e:  # the favourites are enough
            say("  ambientCG's list could not be read (%s); its favourites only" % e)
    return [{"source": "ambientcg", "id": i, "kind": "materials", "name": i, "author": "ambientCG",
             "page": "https://ambientcg.com/view?id=" + i} for i in ids]


def get_ph(item, res, lib):
    files = get_json("%s/files/%s" % (PH_API, item["id"]))
    src = os.path.join(lib, "online", "polyhaven", item["id"])
    got = []
    if item["kind"] == "skies":
        f = pick(files.get("hdri"), res, ["hdr"])
        if not f:
            raise RuntimeError("no sky file")
        dest = os.path.join(lib, "skies", item["id"] + ".hdr")
        fetch(f["url"], dest, f.get("md5", ""), f.get("size", 0), item["name"])
        licence(dest[:-4] + ".license.json", item)
        return {"result": dest, "files": [dest]}, "complete"
    if item["kind"] == "materials":
        maps = {}
        for key, names in (("albedo", ["Diffuse", "diff"]), ("normal", ["nor_gl"]), ("roughness", ["Rough", "rough"]), ("ao", ["AO", "ao"]),
                           ("height", ["Displacement", "disp"])):
            for n in names:
                f = pick(files.get(n), res, ["jpg", "png"])
                if f:
                    dest = os.path.join(src, "%s_%s.%s" % (item["id"], key, f["url"].rsplit(".", 1)[-1].split("?")[0]))
                    fetch(f["url"], dest, f.get("md5", ""), f.get("size", 0), "%s (%s)" % (item["name"], key))
                    maps[key] = dest
                    got.append(dest)
                    break
        if "albedo" not in maps:
            raise RuntimeError("no colour map")
        dims = item.get("dimensions") or []
        tile = float(dims[0]) / 1000.0 if dims and float(dims[0]) > 0 else 2.0
        return {"maps": maps, "tile": tile, "files": got}, "downloaded"
    f = pick(files.get("gltf"), res, ["gltf"])
    if not f:
        raise RuntimeError("no glTF")
    main = os.path.join(src, f["url"].rsplit("/", 1)[-1].split("?")[0])
    fetch(f["url"], main, f.get("md5", ""), f.get("size", 0), item["name"])
    got.append(main)
    for rel, part in (f.get("include") or {}).items():
        dest = os.path.join(src, *rel.split("/"))
        fetch(part["url"], dest, part.get("md5", ""), part.get("size", 0), "%s (%s)" % (item["name"], rel))
        got.append(dest)
    cat = next((PH_CATEGORY[c] for c in item.get("categories", []) if c in PH_CATEGORY), "props")
    return {"model": main, "category": cat, "files": got}, "downloaded"


def get_acg(item, res, lib):
    src = os.path.join(lib, "online", "ambientcg", item["id"])
    z = os.path.join(src, "%s_%s-JPG.zip" % (item["id"], res.upper()))
    fetch(ACG_GET % (item["id"], res.upper(), "JPG"), z, label=item["name"])
    maps = {}
    try:
        with zipfile.ZipFile(z) as zf:
            for n in zf.namelist():
                low = n.lower()
                key = ("albedo" if low.endswith("_color.jpg") else "normal" if "_normalgl." in low else
                       "roughness" if "_roughness." in low else "ao" if "_ambientocclusion." in low else
                       "height" if "_displacement." in low else "")
                if key:
                    dest = os.path.join(src, os.path.basename(n))
                    with zf.open(n) as a, open(dest, "wb") as b:
                        shutil.copyfileobj(a, b)
                    maps[key] = dest
    except zipfile.BadZipFile:
        os.remove(z)
        raise RuntimeError("the download was not a zip file; it was removed so the next run fetches it again")
    if "albedo" not in maps:
        raise RuntimeError("no colour map in the download")
    return {"maps": maps, "tile": 2.0, "files": list(maps.values())}, "downloaded"


def main():
    ap = argparse.ArgumentParser(description="Download Oriel's starter pack of free assets.")
    ap.add_argument("--size", choices=["small", "standard", "large"], default="standard")
    ap.add_argument("--only", default="", help="kinds to get: skies,materials,models")
    ap.add_argument("--dest", default="", help="the library folder (default: Oriel's own)")
    ap.add_argument("--list", action="store_true", help="show the plan, download nothing")
    a = ap.parse_args()
    lib = os.path.abspath(a.dest) if a.dest else user_library()
    only = set(x.strip() for x in a.only.split(",") if x.strip())
    pack = find_pack()
    man = Manifest(lib)
    plan = []
    for g in pack.get("groups", []):
        if g.get("requires") == "login" or (only and g["kind"] not in only):
            continue
        if int(g.get("count", {}).get(a.size, 0)) <= 0:
            continue
        res = g.get("resolution", {}).get(a.size, "2k")
        try:
            items = ph_plan(g, a.size) if g["source"] == "polyhaven" else acg_plan(g, a.size)
        except Exception as e:
            say("Could not plan %s %s: %s" % (g["source"], g["kind"], e))
            continue
        plan += [(it, res) for it in items]
    say("Library: %s" % lib)
    say("Plan: %d assets (%s pack). Already here: %d." % (len(plan), a.size, sum(man.done(i["source"], i["id"]) for i, _ in plan)))
    if a.list:
        for it, res in plan:
            say("  %-10s %-9s %-40s %s%s" % (it["source"], it["kind"], it["name"][:40], res, "  (here)" if man.done(it["source"], it["id"]) else ""))
        return 0
    failed = []
    down = set()       # sources that could not be reached this time
    try:
        for n, (it, res) in enumerate(plan, 1):
            if man.done(it["source"], it["id"]):
                continue
            if it["source"] in down:
                failed.append("%s: %s could not be reached" % (it["name"], it["source"]))
                continue
            say("[%d/%d] %s (%s, %s)" % (n, len(plan), it["name"], it["source"], it["kind"]))
            try:
                result, state = get_ph(it, res, lib) if it["source"] == "polyhaven" else get_acg(it, res, lib)
                entry = {k: v for k, v in it.items() if k in ("source", "id", "name", "kind", "author")}
                entry.update({"state": state, "license": "CC0-1.0", "url": it["page"], "added": time.strftime("%Y-%m-%dT%H:%M:%S"),
                              "files": result.pop("files", [])})
                entry["result" if state == "complete" else "pending"] = result.get("result", result)
                man.put(entry)
            except Stopped:
                raise
            except Exception as e:
                failed.append("%s: %s" % (it["name"], e))
                say("  not downloaded: %s" % e)
                if isinstance(e, urllib.error.URLError) and not isinstance(e, urllib.error.HTTPError):
                    down.add(it["source"])
                    say("  %s cannot be reached now; its other assets are left for the next run" % it["source"])
            time.sleep(0.2)    # polite to the servers
    except (Stopped, KeyboardInterrupt):
        say("\nStopped. Everything downloaded so far is kept; run again to carry on.")
        return 130
    say("Done: %d of %d assets are in %s." % (sum(man.done(i["source"], i["id"]) for i, _ in plan), len(plan), lib))
    if failed:
        say("Not downloaded (run again to retry):\n  " + "\n  ".join(failed))
    say("Open Oriel's Online page to add the new materials and models to the library. "
        "Poly Haven assets: powered by Poly Haven (CC0). ambientCG: CC0.")
    return 0 if not failed else 1


if __name__ == "__main__":
    sys.exit(main())
