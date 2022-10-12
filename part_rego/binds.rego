package docker.authz

allow {
    not binds
}

binds { # allow no binds or only allowed binds
    input.Body.HostConfig.Binds != null 
    not binds_good_array
}

binds_good_array {
    is_array(input.Body.HostConfig.Binds)
    not binds_strings
    not bad_strings
}

binds_strings {
    val := input.Body.HostConfig.Binds[_]
    not is_string(val)
}

bad_strings {
    val := input.Body.HostConfig.Binds[_]
    check_string(val)
}

check_string(s) { #not allow host file/folder binds except 3 allowed ones
    startswith(s,"/")
    s!= "/var/run/docker.sock:/var/run/docker.sock"
    s!= "/cache"
    s!= "/usr/local/bin/das-cli:/usr/local/bin/das-cli:ro"
}