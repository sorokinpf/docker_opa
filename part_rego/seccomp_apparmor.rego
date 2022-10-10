package docker.authz

allow {
    not seccomp_apparmor_unconfined
}

seccomp_apparmor_unconfined {
    contains(input.Body.HostConfig.SecurityOpt[_], "unconfined")
}