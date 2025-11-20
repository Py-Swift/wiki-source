# Kivy-iOS Recipes vs PEP 730 Wheels Coverage

**Generated:** 2025-11-20 17:37:12  
**Kivy-iOS Recipes:** 47  
**Recipes Requiring iOS Wheels:** 35 (excluding 8 pure Python, 4 build-time only)  
**PEP 730 iOS Wheels (PySwift):** 29  
**Coverage:** 23/35 (66%)

---

## Summary

Of the 47 kivy-ios recipes:
- 8 are pure Python packages that don't need iOS wheels (can be installed via pip)
- 4 are build-time only recipes (hostopenssl, hostpython3, python3, freetype)

For the remaining **35 recipes that require runtime iOS wheels**, PySwift provides **23 pre-built PEP 730 wheels** (including bundled SDL frameworks), representing **66% coverage**. An additional 2 packages (pillow, pymunk) have official PEP 730 wheels available on PyPI.

PEP 730 wheels offer a modern alternative to the traditional kivy-ios recipe system, eliminating the need to compile packages from source on iOS.

---

## ✅ Covered Recipes (25)

### PySwift PEP 730 Wheels (23)

These kivy-ios recipes have equivalent PEP 730 wheels provided by anaconda PySwift/KivySchool:

| Kivy-iOS Recipe | PEP 730 Wheel | Status |
|-----------------|---------------|--------|
| `angle` | `kivy-sdl3-angle` | ✅ Available |
| `audiostream` | `ios` | ✅ Available |
| `ios` | `ios` | ✅ Available |
| `kivy` | `kivy-sdl2` | ✅ Available |
| `kiwisolver` | `kiwisolver` | ✅ Available |
| `libffi` | `cffi` | ✅ Available |
| `libpng` | `libpng` | ✅ Available |
| `materialyoucolor` | `materialyoucolor` | ✅ Available |
| `matplotlib` | `matplotlib` | ✅ Available |
| `netifaces` | `netifaces` | ✅ Available |
| `numpy` | `numpy` | ✅ Available |
| `pycrypto` | `pycryptodome` | ✅ Available |
| `plyer` | `pyobjus` (dependency) | ✅ Available |
| `pyobjus` | `pyobjus` | ✅ Available |
| `sdl2` | `kivy-sdl2` | ✅ Available |
| `sdl2_image` | `kivy-sdl2` (bundled) | ✅ Available |
| `sdl2_mixer` | `kivy-sdl2` (bundled) | ✅ Available |
| `sdl2_ttf` | `kivy-sdl2` (bundled) | ✅ Available |
| `sdl3` | `kivy-sdl3-angle` | ✅ Available |
| `sdl3_image` | `kivy-sdl3-angle` (bundled) | ✅ Available |
| `sdl3_mixer` | `kivy-sdl3-angle` (bundled) | ✅ Available |
| `sdl3_ttf` | `kivy-sdl3-angle` (bundled) | ✅ Available |

### Official PyPI PEP 730 Wheels (2)

These packages have official iOS wheels available on PyPI:

| Kivy-iOS Recipe | PyPI Package | Status |
|-----------------|--------------|--------|
| `pillow` | `pillow` | ✅ Available on PyPI |
| `pymunk` | `pymunk` | ✅ Available on PyPI |

---

## 🐍 Pure Python Recipes (8)

These recipes are for pure Python packages that can be installed directly via pip - no iOS wheels needed:

| Kivy-iOS Recipe | Installation |
|-----------------|--------------|
| `click` | `pip install click` |
| `flask` | `pip install flask` |
| `itsdangerous` | `pip install itsdangerous` |
| `jinja2` | `pip install jinja2` |
| `markupsafe` | `pip install markupsafe` |
| `pykka` | `pip install pykka` |
| `pyyaml` | `pip install pyyaml` |
| `werkzeug` | `pip install werkzeug` |

---

## ⚠️ Not Covered Recipes (10)

These kivy-ios recipes require runtime binary wheels but don't have PEP 730 equivalents yet:

### System Libraries (4)

Low-level C libraries, typically bundled with other packages:

| Kivy-iOS Recipe | Notes |
|-----------------|-------|
| `libcurl` | Usually bundled with dependent packages |
| `libjpeg` | Usually bundled with pillow |
| `libzbar` | Usually bundled with zbarlight |
| `openssl` | Usually bundled with cryptography |

### Other Packages (6)

| Kivy-iOS Recipe | Type | Notes |
|-----------------|------|-------|
| `curly` | Other | Check PyPI for availability |
| `cymunk` | Physics Engine | Alternative to pymunk - may not be actively maintained |
| `ffmpeg` | Media Library | Check PyPI for availability |
| `ffpyplayer` | Media Player | Check PyPI for availability |
| `kivent_core` | Deprecated/Broken | May not be actively maintained |
| `photolibrary` | iOS Library | Check PyPI for availability |
| `py3dns` | Deprecated/Broken | May not be actively maintained |
| `zbarlight` | Barcode Scanner | Check PyPI for availability |

---

## 📦 PEP 730-Only Packages

These packages are available as PEP 730 wheels from PySwift but don't have kivy-ios recipes:

`aiohttp`, `apsw`, `bcrypt`, `bitarray`, `brotli`, `contourpy`, `coverage`, `cryptography`, `greenlet`, `lru-dict`, `msgpack`, `orjson`, `pendulum`, `pydantic-core`, `regex`, `sqlalchemy`, `watchdog`, `zeroconf`

---

## Notes

### What is PEP 730?

[PEP 730](https://peps.python.org/pep-0730/) is a Python Enhancement Proposal that defines the standard for distributing iOS and macOS binary wheels. It introduces platform tags like `ios_arm64` and `macosx_*` that allow pip to install pre-compiled packages on Apple platforms.

Before PEP 730, iOS developers had to compile all C extensions from source using tools like kivy-ios. With PEP 730 wheels, packages can be installed directly via pip, just like on desktop platforms.

PySwift provides a collection of PEP 730 compliant wheels for iOS, making it much easier to use popular Python packages in iOS apps.

### SDL Libraries
The SDL2 and SDL3 frameworks are bundled into comprehensive wheels:
- `kivy-sdl2` - Includes SDL2, SDL2_image, SDL2_mixer, SDL2_ttf
- `kivy-sdl3-angle` - Includes SDL3, SDL3_image, SDL3_mixer, SDL3_ttf, ANGLE

### Pure Python Packages
8 kivy-ios recipes are for pure Python packages that can be installed directly via pip on iOS without needing special wheels or recipes (Flask, Jinja2, Click, etc.).

### Build-Time Only Recipes
4 recipes (`hostopenssl`, `hostpython3`, `python3`, `freetype`) are build-time dependencies only - not needed for runtime wheel installation. Freetype has iOS builds but is only required when producing wheels, not when using them.

### System Libraries
Low-level C libraries (OpenSSL, libffi, etc.) are often included as dependencies of higher-level packages and don't need separate wheel distributions.

---

**Generated by:** PySwiftKit Documentation Tool  
**Sources:**
- Kivy-iOS: [https://github.com/kivy/kivy-ios/tree/master/kivy_ios/recipes](https://github.com/kivy/kivy-ios/tree/master/kivy_ios/recipes)
- PEP 730 Wheels: [https://pypi.anaconda.org/pyswift/simple](https://pypi.anaconda.org/pyswift/simple)
- PEP 730 Specification: [https://peps.python.org/pep-0730/](https://peps.python.org/pep-0730/)
