import glob
import json
import sys
import os
import packer
from tqdm import tqdm
from lib import packerMod


def build_base(packer_var_file, replace_existing, vmServer=None, prependString = ""):
    TEMP_DIR="tmp"

    vm_name = packer_var_file.split('/').pop().strip(".json")

    temp_path = os.path.join("..", "..", TEMP_DIR, prependString + vm_name)

    if not os.path.exists(temp_path):
        os.makedirs(temp_path)

    output = vm_name + "_virtualbox.box"

    only = ['virtualbox-iso']

    with open(os.path.join("..", "..", packer_var_file)) as packer_var_source:
        packer_vars = json.load(packer_var_source)

    packer_vars.update({
        "vm_name": prependString + vm_name,
        "output": os.path.join("..", "..", "box", output)
    })

    # TODO: make this detect from either var file or vm_name
    packerfile = "macos.json"

    packer_obj = packerMod(packerfile)
    packer_obj.update_config(packer_vars)

    packerfile = os.path.join(temp_path, vm_name + ".json")
    packer_obj.save_config(packerfile)


    out_file = os.path.join(temp_path, "output.log")
    err_file = os.path.join(temp_path, "error.log")

    p = packer.Packer(str(packerfile), only=only, vars=packer_vars,
                      out_iter=out_file, err_iter=err_file)

    p.build(parallel=True, debug=False, force=False)

    return p


def main(argv):

    targets = glob.glob('templates/*.json')
    print(targets)

    os.chdir("boxcutter/macos")

    for target in tqdm(targets):
        build_base(target, replace_existing=False, vmServer=None, prependString="")

    return False

if __name__ == "__main__":
    main(sys.argv)

