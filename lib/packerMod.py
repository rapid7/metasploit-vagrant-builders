import json


class packerMod:
    local_packer = {}

    def __init__(self, packer_file):
        with open(packer_file) as packer_source:
            self.local_packer = json.load(packer_source)

    def update_config(self, template):
        for provisioner in self.local_packer['provisioners']:
            if 'scripts' in provisioner:
                for script in template['custom_scripts']:
                    provisioner['scripts'].append(script)
                break
        for processor in self.local_packer["post-processors"]:
            if processor['type'] == 'vagrant':
                processor.update({
                    "output": template['output']
                })
                break

    def save_config(self, path):
        with open(path, "w") as packer_handle:
            json.dump(self.local_packer, packer_handle, indent=2, sort_keys=False)
