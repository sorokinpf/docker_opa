package docker.authz

allow {
    not ipc
}

ipc { #only string values "none", "private" and "" are allowed
    not is_string(input.Body.HostConfig.IpcMode)
} {
    input.Body.HostConfig.IpcMode != "none"
    input.Body.HostConfig.IpcMode != "private"
    input.Body.HostConfig.IpcMode != ""
} 