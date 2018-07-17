This repository hold tools for creating vagrant systems used by the Metasploit Framework to build and release artifacts.

To build these systems:
* install `virtualbox` and `packer` and `python`
* `pip install vm-automation`
* `pip install tqdm`
* `pip install python-packer`
* execute `python buildBoxes.py`

Build systems for macOS can only be created on macOS. Installers are obtained from r7 controlled s3 bucket. 

