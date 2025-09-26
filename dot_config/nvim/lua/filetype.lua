vim.filetype.add {
  pattern = {
    ['.*/.github/workflows/.*%.yml'] = 'yaml.ghaction',
    ['.*/.github/workflows/.*%.yaml'] = 'yaml.ghaction',
    -- Ansible playbooks and tasks
    ['.*/ansible/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/playbooks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/tasks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/handlers/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/vars/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/defaults/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/group_vars/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/host_vars/.*%.ya?ml'] = 'yaml.ansible',
    -- Ansible inventory files
    ['.*/inventory/.*%.ya?ml'] = 'yaml.ansible',
    -- Common Ansible file names
    ['.*playbook%.ya?ml'] = 'yaml.ansible',
    ['.*site%.ya?ml'] = 'yaml.ansible',
    ['.*main%.ya?ml'] = 'yaml.ansible',
  },
  filename = {
    -- Ansible configuration files
    ['ansible.cfg'] = 'dosini',
    ['.ansible.cfg'] = 'dosini',
  },
}
