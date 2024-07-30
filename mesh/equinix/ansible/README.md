git clone https://github.com/SanjeevKGupta/gcp-microservices-demo.git
source ENV_MESH_MANAGER
cat mcnm_config.yaml.tmpl | envsubst > mcnm_config.yaml
cat playbook-mesh.yaml.tmpl | envsubst > playbook-mesh.yaml
ansible-playbook playbook-mesh.yaml
