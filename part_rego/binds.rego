package docker.authz

allow {
    not binds
}

binds { # allow no binds or empty binds
        # this blocks any volume mount, not only host filesystem
    input.Body.HostConfig.Binds != null 
    not binds_array
}

binds_array {
    is_array(input.Body.HostConfig.Binds)
    count(input.Body.HostConfig.Binds) == 0
}