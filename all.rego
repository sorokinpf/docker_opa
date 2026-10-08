package docker.authz

allow = false {
    not allow_full
}

allow = true {
    allow_full
}

allow_full {
    not plugins
    not exec
    not archive
    not export
    # not stop - no way to stop container
    not kill
    not pause
    not restart
    not update
    # not attach - no way to read container output
    # not logs - no way to read container output
    not commit
    not events
    not session
    not swarm
    not services
    not tasks
    not nodes
    not secrets
    not configs
    not volume
    not volumes_ls
    not binds
    not mounts
    not volumes_from
    not capadd
    not capabilities
    not devices
    not device_cgroup_rules
    not cgroup_parent
    not ipc
    not network
    not pid
    # not ports - low severity
    not privileged
    not seccomp_apparmor_unconfined
    not systempaths
    not sysctls
} {
    input.Headers["Opa-Bypass"] == "your_secret_password_here"
}

plugins { # docker plugin
    val := PathArr[_]
    val == "plugins"
}
 
exec { # docker exec 
    val := PathArr[_]
    val == "exec"
}

archive { # docker cp
    val := PathArr[_]
    val == "archive"
}

export { # docker export 
    val := PathArr[_]
    val == "export"
}

stop { # docker stop 
    val := PathArr[_]
    val == "stop"
}

kill { #docker kill
    val := PathArr[_]
    val == "kill"
}

pause { #docker pause
    val := PathArr[_]
    val == "pause"
}

restart { #docker restart
    val := PathArr[_]
    val == "restart"
}

update { #docker update
    val := PathArr[_]
    val == "update"
}

attach { #docker attach
    val := PathArr[_]
    val == "attach"
}

logs { #docker logs
    val := PathArr[_]
    val == "logs"
}

commit { # docker commit
    val := PathArr[_]
    val == "commit"
}

events { # docker events 
    val := PathArr[_]
    val == "events"}
    
session { # session API method
    val := PathArr[_]
    val == "session"}

swarm { # docker swarm
    val := PathArr[_]
    val == "swarm"
}

services { # docker service (part of swarm)
    val := PathArr[_]
    val == "services"
}

tasks { # tasks API methods
    val := PathArr[_]
    val == "tasks"
}

nodes { # docker nodes (part of swarm)
    val := PathArr[_]
    val == "nodes"
}

secrets { # docker secrets (part of swarm)
    val := PathArr[_]
    val == "secrets"
}

configs { # docker config (part of swarm)
    val := PathArr[_]
    val == "configs"
}

volume { # allow create only simple volumes. No options allowed. DriverOpts is null or empty object.
    input.Body.DriverOpts != null 
    not driveropts_empty_object
}

driveropts_empty_object {
    is_object(input.Body.DriverOpts)
    count(input.Body.DriverOpts) == 0
}

volumes_ls {
    input.Method == "GET"
    count(PathArr) == 3
    PathArr[2] == "volumes"
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
    s!= "/var/run/docker.sock:/var/run/docker.sock:rw"
    s!= "/cache"
    s!= "/usr/local/bin/das-cli:/usr/local/bin/das-cli:ro"
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

volumes_from { # --volumes-from inherits ALL mounts of another container (docker.sock, /cache, ...),
               # so it bypasses the Binds allow list. Only null and empty arrays are allowed.
    input.Body.HostConfig.VolumesFrom != null
    not volumes_from_empty_array
}

volumes_from_empty_array {
    is_array(input.Body.HostConfig.VolumesFrom)
    count(input.Body.HostConfig.VolumesFrom) == 0
}

capadd { # allow CapAdd == null or CapAdd == [] (empty array)
    input.Body.HostConfig.CapAdd != null 
    not capadd_array
}

capadd_array {
    is_array(input.Body.HostConfig.CapAdd)
    count(input.Body.HostConfig.CapAdd) == 0
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

devices { #only null and empty arrays are allowed
    input.Body.HostConfig.Devices != null
    not devices_array
} 

devices_array {
    is_array(input.Body.HostConfig.Devices)
    count(input.Body.HostConfig.Devices) == 0
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

cgroup_parent { #only string value "" is allowed, i.e. the default cgroup
    input.Body.HostConfig.CgroupParent != null
    cgroup_parent_bad_string
}

cgroup_parent_bad_string {
    not is_string(input.Body.HostConfig.CgroupParent)
} {
    input.Body.HostConfig.CgroupParent != ""
}

ipc { #(only string values "none", "private" and "") OR null are allowed 
    input.Body.HostConfig.IpcMode != null
    ipc_bad_string
}

ipc_bad_string {
    not is_string(input.Body.HostConfig.IpcMode)
} {
    input.Body.HostConfig.IpcMode != "none"
    input.Body.HostConfig.IpcMode != "private"
    input.Body.HostConfig.IpcMode != ""
    
} 

#null or (string and string is good)
# not (not null and (not string or not string is good))


network { #(any string values except "host" and "bridge") OR null are allowed
    input.Body.HostConfig.NetworkMode != null
    network_bad_string
}

network_bad_string {
    not is_string(input.Body.HostConfig.NetworkMode)
} {
    input.Body.HostConfig.NetworkMode == "host"
}

pid { #only string values "" are allowed
    input.Body.HostConfig.PidMode != null
    pid_bad_string
} 

pid_bad_string { #only string values "" are allowed
    not is_string(input.Body.HostConfig.PidMode)
} {
    input.Body.HostConfig.PidMode != ""
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

privileged {
    input.Body.HostConfig.Privileged != null
    privileged_bad
} 

privileged_bad {
    input.Body.HostConfig.Privileged
}

seccomp_apparmor_unconfined {
    contains(input.Body.HostConfig.SecurityOpt[_], "unconfined")
}

systempaths { # docker masks /proc/kcore, /proc/keys, /sys/firmware, ... and mounts /proc/sys,
              # /proc/sysrq-trigger, ... read-only. An empty array turns that off. Writable
              # /proc/sys means writable kernel.core_pattern, which is a host escape.
              # docker cli sends null here, so any explicit value is forbidden.
              # NOTE: `--security-opt systempaths=unconfined` is translated by the cli into empty
              # MaskedPaths/ReadonlyPaths, so the SecurityOpt rule above does not catch it.
    input.Body.HostConfig.MaskedPaths != null
} {
    input.Body.HostConfig.ReadonlyPaths != null
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

PathArr :=split(ClearPath,"/") #some versions of docker do not send input.PathArr. So it's more reliable to compute PathArr ourself
ClearPath:= split(input.Path,"?")[0]
