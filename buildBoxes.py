import getopt
import glob
import json
import sys
import os
import packer
import sh
from tqdm import tqdm
from lib import packerMod
from lib import serverHelper


def build_base(packer_var_file, root_path, replace_existing=False, vmServer=None, prependString=""):
    temp_dir = "tmp"
    abs_root = os.path.abspath(root_path)

    vm_name = packer_var_file.split('/').pop().strip(".json")

    temp_path = os.path.join(abs_root, temp_dir, prependString + vm_name)

    if not os.path.exists(temp_path):
        os.makedirs(temp_path)

    output = vm_name + "_virtualbox.box"

    only = ['virtualbox-iso']

    if vmServer.get_config() is not None:
        output = vm_name + "_vmware.box"
        only = ['vmware-iso']

    with open(os.path.join(root_path, packer_var_file)) as packer_var_source:
        packer_vars = json.load(packer_var_source)

    if packer_vars["run_in_path"]:
        os.chdir(packer_vars["packer_template_path"])
        packer_file = packer_vars["packer_template"]
    else:
        packer_file = os.path.join(packer_vars["packer_template_path"], packer_vars["packer_template"])

    packer_vars.update({
        "vm_name": prependString + vm_name,
        "output": os.path.join(abs_root, "box", output)
    })

    packer_obj = packerMod(packer_file)

    if vmServer.get_esxi() is not None:
        packer_vars.update(vmServer.get_config())
        packer_obj.use_esxi_config()

    packer_obj.update_config(packer_vars)

    packer_file = os.path.join(temp_path, vm_name + ".json")
    packer_obj.save_config(packer_file)

    out_file = os.path.join(temp_path, "output.log")
    err_file = os.path.join(temp_path, "error.log")

    p = packer.Packer(str(packer_file), only=only, vars=packer_vars,
                      out_iter=out_file, err_iter=err_file)

    vm = vmServer.get_vm(prependString + vm_name)
    if vm is not None:
        if replace_existing:
            vmServer.remove_vm(prependString + vm_name)
        else:
            os.chdir(abs_root)
            return p  # just return without exec since ret value is not checked anyways

    try:
        p.build(parallel=True, debug=False, force=False)
    except sh.ErrorReturnCode:
        print "Error: build of " + prependString + vm_name + " returned non-zero"
        return p
    os.chdir(abs_root)

    return p


def main(argv):

    prependString = ""
    replace_vms = False
    esxi_file = "esxi_config.json"

    try:
        opts, args = getopt.getopt(argv[1:], "c:hp:r", ["prependString="])
    except getopt.GetoptError:
        print argv[0] + ' -n <numProcessors>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print argv[0] + " [options]"
            print '-c <file>, --esxiConfig=<file>   use alternate hypervisor config file'
            print '-p <string>, --prependString=<file>   prepend string to the beginning of VM names'
            print '-r, --replace                     replace existing msf_host'
            sys.exit()
        elif opt in ("-c", "--esxiConfig"):
            esxi_file = arg
        elif opt in ("-p", "--prependString"):
            prependString = arg
        elif opt in ("-r", "--replace"):
            replace_vms = True

    vm_server = serverHelper(esxi_file)

    targets = glob.glob('templates/*.json')
    print(targets)

    for target in tqdm(targets):
        build_base(target, os.curdir, replace_existing=replace_vms, vmServer=vm_server, prependString=prependString)

    return False

if __name__ == "__main__":
    main(sys.argv)

