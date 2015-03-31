{% from "salt/map.jinja" import salt_settings with context %}

include:
  - salt.master

# TODO Make this run on other systems besides ubuntu
api-deps:
  pkg.installed:
    - pkgs:
      - python-service-identity
      - python-cherrypy

localhost_crt:
   module.run:
     - name: tls.create_self_signed_cert
     - onlyif:
       - test ! -f /etc/pki/tls/certs/localhost.crt

salt-api:
{% if salt_settings.install_packages %}
  pkg.installed:
    - name: {{ salt_settings.salt_api }}
{% endif %}
  service.running:
    - name: {{ salt_settings.api_service }}
    - require:
      - service: {{ salt_settings.master_service }}
    - watch:
      - pkg: salt-master
