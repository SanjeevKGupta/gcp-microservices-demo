env_var_check = $(if $($1),,$(error $1 is not set. $2, e.g. export $1=$3))

#export ARCH ?= $(shell hzn architecture)
export ARCH ?= amd64

$(call env_var_check,EDGE_OWNER,Set to com or your two-letter initials,<sg.edge>)
$(call env_var_check,EDGE_DEPLOY,Set to a meaningful value,<ex.mesh.rhsi.helloworld>)
#$(call env_var_check,HZN_ORG_ID,Set to org-id or tenant-id,<poc>)
#$(call env_var_check,HZN_EXCHANGE_USER_AUTH,Set to ohuser and auth key cred,ohuser:<your-ohuser-auth-key>)
$(call env_var_check,CR_HOST,Set to container registry host,<us.icr.io>)
$(call env_var_check,CR_HOST_NAMESPACE,Set to your namesapce within the container registry,<mesh-poc>)
$(call env_var_check,CR_HOST_USERNAME,Set to your username of the container registry,<iamapikey>)
$(call env_var_check,CR_APP_API_KEY_RO_PULL,Set to read-only api-key of the container registry,<cr-app-api-key-ro-pull>)
$(call env_var_check,CR_APP_API_KEY_RW_PUSH,Set to read-write api-key of the container registry,<cr-app-api-key-rw-push>)
