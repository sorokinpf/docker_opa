package docker.authz

allow {
    not volumes_from
}

volumes_from { # --volumes-from inherits ALL mounts of another container (docker.sock, /cache, ...),
               # so it bypasses the Binds allow list. Only null and empty arrays are allowed.
    input.Body.HostConfig.VolumesFrom != null
    not volumes_from_empty_array
}

volumes_from_empty_array {
    is_array(input.Body.HostConfig.VolumesFrom)
    count(input.Body.HostConfig.VolumesFrom) == 0
}
