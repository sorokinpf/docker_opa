# docker_opa

Rules for [Docker OPA Plugin](https://www.openpolicyagent.org/docs/latest/docker-authorization/)

`all.rego` - all rules in one rego file.

`part_rego` - directory with one-rule-file examples.

## Rules

Forbidden:
- run privileged (`--privileged`)
- add capabilities (`--cap-add` and `HostConfig.Capabilities`, a separate API 1.40 field that
  holds the resulting capability set, so checking `CapAdd` alone is not enough)
- use IPC parameter (`--ipc`)
- mount host volumes except allowed once (`-v` and `--mount`; `--mount` must be checked separately
  from `Binds`, and it can also carry volume driver options, bypassing the volume create rule)
- inherit mounts of another container (`--volumes-from`): it gives away `docker.sock`, `/cache` and
  everything else the target container has, without naming a single path
- ~~port publishing (`-P` and `-p`)~~ (not so security issue)
- use PID host namespace  (`--pid`)
- use not default network (`--network`)
- use not default cgroup (`--cgroup-parent`)
- use host devices (`--device` and `--device-cgroup-rule`: the latter plus `CAP_MKNOD`, which is in
  the docker default capability set, gives raw host disks without `--device` at all)
- disable seccomp and apparmor(`--security-opt apparmor=unconfined` and `--security-opt seccomp=unconfined`) ATTENTION: two options exists `apparmor:unconfined` and `apparmor=unconfined`
- unmask `/proc` and `/sys` (`--security-opt systempaths=unconfined`, i.e. empty
  `HostConfig.MaskedPaths`/`ReadonlyPaths`). ATTENTION: the cli translates this option into those
  two fields instead of passing it in `SecurityOpt`, so the seccomp/apparmor rule does not catch
  it. Writable `/proc/sys` means writable `kernel.core_pattern`, which is a host escape
- set sysctls (`--sysctl`)
- `docker plugin`
- `docker exec`
- `docker cp` (both sides)
- ~~docker stop~~ (we need to kill our dangling containers)
- `docker kill`
- `docker pause`
- `docker restart`
- `docker update`
- ~~docker attach~~ (we need read logs of our containers)
- ~~docker logs~~ (we need read logs of our containers)
- `docker commit`
- ~~docker checkpoint~~ (experimental feature)
- `docker volume ls` and `docker volume create` with driver options

## Admin access

You can use backdoor password in `Opa-Bypass` header. Modify `~/.docker/config.json`:
```
{ ... ,
	"HttpHeaders": {
      "Opa-Bypass": "your_secret_password_here"
      },
      ...
}
```

`your_secret_password_here` must match in `~/.docker/config.json` and rule in `all.rego` file.

!!!Change `your_secret_password_here` please.

