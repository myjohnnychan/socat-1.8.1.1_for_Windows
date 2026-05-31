# socat 1.8.1.1 for Windows

This repository builds `socat` 1.8.1.1 for Windows x86_64 with Cygwin on
GitHub Actions.

The source archive in this repository was made from:

`C:\Users\myjoh\Downloads\socat-1.8.1.1\socat-1.8.1.1`

## Build

Open the **Actions** tab, select **Build socat for Windows**, and run the
workflow. The workflow also runs automatically when changes are pushed to
`main`.

The build artifact contains:

- `socat.exe`
- `filan.exe` and `procan.exe` when built
- required `cyg*.dll` runtime dependencies
- upstream documentation and license files

Download the artifact named:

`socat-1.8.1.1-cygwin-x86_64`

## Local Source Build

The workflow follows the upstream build flow:

```bash
tar -xzf socat-1.8.1.1.tar.gz
cd socat-1.8.1.1
./configure --enable-default-ipv=4
make
```

## Notes

This is a Cygwin build. Keep the included `cyg*.dll` files next to
`socat.exe` when running it outside a full Cygwin installation.
