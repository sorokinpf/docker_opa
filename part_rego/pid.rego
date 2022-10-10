package docker.authz

allow {
    not pid
}

pid { #only string values "" are allowed
    not is_string(input.Body.HostConfig.PidMode)
} {
    input.Body.HostConfig.PidMode != ""
} 