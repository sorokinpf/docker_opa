package docker.authz

allow {
    not network
}

network { #any string values except "host" and "bridge" are allowed
    not is_string(input.Body.HostConfig.NetworkMode)
} {
    input.Body.HostConfig.NetworkMode == "host"
} {
    input.Body.HostConfig.NetworkMode == "bridge"
}
