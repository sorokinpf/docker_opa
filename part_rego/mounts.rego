package docker.authz

allow {
    not mounts
}

mounts { # --mount is another way to say -v, so Binds rules must not be the only check.
         # Only null/absent/empty array are allowed. Beware: Mounts can also carry
         # volume driver options (VolumeOptions.DriverConfig.Options), bypassing `volume` rule.
    input.Body.HostConfig.Mounts != null
    not mounts_empty_array
}

mounts_empty_array {
    is_array(input.Body.HostConfig.Mounts)
    count(input.Body.HostConfig.Mounts) == 0
}
