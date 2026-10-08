package docker.authz

allow {
    not sysctls
}

sysctls { # docker allows namespaced sysctls only, but kernel.shm* can eat host memory and with a
          # shared netns net.* settings of another container are affected.
          # Only null and empty objects are allowed.
    input.Body.HostConfig.Sysctls != null
    not sysctls_empty_object
}

sysctls_empty_object {
    is_object(input.Body.HostConfig.Sysctls)
    count(input.Body.HostConfig.Sysctls) == 0
}
