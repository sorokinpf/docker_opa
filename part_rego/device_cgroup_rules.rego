package docker.authz

allow {
    not device_cgroup_rules
}

device_cgroup_rules { #--device-cgroup-rule 'b *:* rwm' plus CAP_MKNOD (it is in the docker default
                      #capability set) gives access to raw host disks without --device at all.
                      #Only null and empty arrays are allowed.
    input.Body.HostConfig.DeviceCgroupRules != null
    not device_cgroup_rules_empty_array
}

device_cgroup_rules_empty_array {
    is_array(input.Body.HostConfig.DeviceCgroupRules)
    count(input.Body.HostConfig.DeviceCgroupRules) == 0
}
