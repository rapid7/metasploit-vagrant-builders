This repository hold tools for creating vagrant systems used by the Metasploit Framework to build and release artifacts.

To build these systems:
* install `virtualbox` and `packer` and `python`
* `pip install vm-automation`
* `pip install tqdm`
* execute `python buildBoxes.py`

Build systems for macOS can only be created on macOS and require obtaining installers, currently 10.9 installer is required to exist in the `iso` path.

