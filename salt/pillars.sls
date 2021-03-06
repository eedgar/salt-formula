{% set processed_gitdirs = [] %}
{% set processed_basedirs = [] %}

{% from "salt/pillars.jinja" import pillars_git_opt with context %}

# Loop over all pillars listed in pillar data
{% for env, entries in salt['pillar.get']('salt_pillars:list', {}).items() %}
{% for entry in entries %}

{% set basedir = pillars_git_opt(env, 'basedir')|load_yaml %}
{% set gitdir = '{0}/{1}'.format(basedir, entry) %}
{% set update = pillars_git_opt(env, 'update')|load_yaml %}

# Setup the directory hosting the Git repository
{% if basedir not in processed_basedirs %}
{% do processed_basedirs.append(basedir) %}
{{ basedir }}:
  file.directory:
    {%- for key, value in salt['pillar.get']('salt_pillars:basedir_opts',
                                             {'makedirs': True}).items() %}
    - {{ key }}: {{ value }}
    {%- endfor %}
{% endif %}

# Setup the pillars Git repository
{% if gitdir not in processed_gitdirs %}
{% do processed_gitdirs.append(gitdir) %}
{% set options = pillars_git_opt(env, 'options')|load_yaml %}
{% set baseurl = pillars_git_opt(env, 'baseurl')|load_yaml %}
{{ gitdir }}:
  git.latest:
    - name: {{ baseurl }}/{{ entry }}.git
    - target: {{ gitdir }}
    {%- for key, value in options.items() %}
    - {{ key }}: {{ value }}
    {%- endfor %}
    - require:
      - file: {{ basedir }}
    {%- if not update %}
    - unless: test -e {{ gitdir }}
    {%- endif %}
{% endif %}

{% endfor %}
{% endfor %}
