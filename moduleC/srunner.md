# Install gitlab runner and deploy

```
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash
```

```
apt install gitlab-runner
```

```
gitlab-runner register  --url https://gitlab.popa.com  --token takefromgitlab
```

vim /etc/gitlab-runner/config.toml 
** - important fields

```
concurrent = 1
check_interval = 0
shutdown_timeout = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "debian"
  **url = "https://gitlab.popa.com"**
  id = 2
  token = "glrt-wnjQ8NitNoazByu91-yt"
  token_obtained_at = 2023-09-12T12:53:14Z
  token_expires_at = 0001-01-01T00:00:00Z
  **executor = "docker"**
//  pre_build_script = """
//  ( apt update -y && apt install ca-certificates -y ) || (apk update && apk add ca-certificates )
//  cp /etc/gitlab-runner/certs/ca.crt /usr/local/share/ca-certificates
//  update-ca-certificates --fresh > /dev/null
#"""
  [runners.cache]
    MaxUploadedArchiveSize = 0
  [runners.docker]
    tls_verify = false
    **image = "alpine:latest"**
    privileged = true //poprobovat bez etogo
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    **volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock", "/etc/ssl/ca.crt:/etc/gitlab-runner/certs/ca.crt:ro"]**
    **network_mode = 'host'**
    shm_size = 0
```
