package docker.authz

allow {
    not capadd
}

capadd { # allow CapAdd == null or CapAdd == [] (empty array)
    input.Body.HostConfig.CapAdd != null 
    not capadd_array
}

capadd_array {
    is_array(input.Body.HostConfig.CapAdd)
    count(input.Body.HostConfig.CapAdd) == 0
}