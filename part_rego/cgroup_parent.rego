package docker.authz

allow {
    not cgroup_parent
}

cgroup_parent { #only string value "" is allowed, i.e. the default cgroup
    input.Body.HostConfig.CgroupParent != null
    cgroup_parent_bad_string
}

cgroup_parent_bad_string {
    not is_string(input.Body.HostConfig.CgroupParent)
} {
    input.Body.HostConfig.CgroupParent != ""
}
