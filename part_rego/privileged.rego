package docker.authz

allow {
    not privileged
}

privileged {
    input.Body.HostConfig.Privileged
} 