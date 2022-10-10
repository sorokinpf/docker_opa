package docker.authz

allow {
    not ports
}

ports { # only null and empty arrays are allowed
    input.Body.HostConfig.PortBindings != null
    not ports_object
} { # PublishAllPorts is forbidden
    input.Body.HostConfig.PublishAllPorts
}

ports_object {
    is_object(input.Body.HostConfig.PortBindings)
    count(input.Body.HostConfig.PortBindings) == 0 
}