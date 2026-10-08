package docker.authz

allow {
    not capabilities
}

capabilities { # HostConfig.Capabilities (API 1.40) is a separate field holding the resulting
               # capability set, so CapAdd == null does not mean "no capabilities added".
    input.Body.HostConfig.Capabilities != null
    not capabilities_empty_array
}

capabilities_empty_array {
    is_array(input.Body.HostConfig.Capabilities)
    count(input.Body.HostConfig.Capabilities) == 0
}
