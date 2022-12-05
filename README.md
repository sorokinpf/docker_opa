# docker_opa

Rules for [Docker OPA Plugin](https://www.openpolicyagent.org/docs/latest/docker-authorization/)

`all.rego` - all rules in one rego file.

`part_rego` - directory with one-rule-file examples.

## Rules

Forbidden:
- run privileged (`--privileged`)
- add capabilities (`--cap-add`)
- use IPC parameter (`--ipc`)
- mount host volumes except allowed once (`-v`)
- ~~port publishing (`-P` and `-p`)~~ (not so security issue)
- use PID host namespace  (`--pid`)
- use not default network (`--network`)
- use not default cgroup (`--cgroup-parent`)
- use host devices (`--device`)
- disable seccomp and apparmor(`--security-opt apparmor=unconfined` and `--security-opt seccomp=unconfined`) ATTENTION: two options exists `apparmor:unconfined` and `apparmor=unconfined`
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

