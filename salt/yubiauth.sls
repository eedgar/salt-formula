{% from "salt/map.jinja" import salt_settings with context %}

yubikey_python:
{% if salt_settings.yubikey_python %}
  pkg.installed:
    - name: {{ salt_settings.yubikey_python }}
{% endif %}
