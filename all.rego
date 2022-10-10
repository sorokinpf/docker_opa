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
    not binds
    not capadd
    not devices
    not ipc
    not network
    not pid
    not ports
    not privileged
    not seccomp_apparmor_unconfined
}

plugins { # docker plugin
	val := input.PathArr[_]
    val == "plugins"
}
 
exec { # docker exec 
	val := input.PathArr[_]
    val == "exec"
}

archive { # docker pc
	val := input.PathArr[_]
    val == "archive"
}

export { # docker export 
	val := input.PathArr[_]
    val == "export"
}

stop { # docker stop 
	val := input.PathArr[_]
    val == "stop"
}

kill { #docker kill
	val := input.PathArr[_]
    val == "kill"
}

pause { #docker pause
	val := input.PathArr[_]
    val == "pause"
}

restart { #docker restart
	val := input.PathArr[_]
    val == "restart"
}

update { #docker update
	val := input.PathArr[_]
    val == "update"
}

attach { #docker attach
	val := input.PathArr[_]
    val == "attach"
}

logs { #docker logs
	val := input.PathArr[_]
    val == "logs"
}

commit { # docker commit
	val := input.PathArr[_]
    val == "commit"
}

events { # docker events 
	val := input.PathArr[_]
    val == "events"}
    
session { # session API method
	val := input.PathArr[_]
    val == "session"}

swarm { # docker swarm
	val := input.PathArr[_]
    val == "swarm"
}

services { # docker service (part of swarm)
	val := input.PathArr[_]
    val == "services"
}

tasks { # tasks API methods
	val := input.PathArr[_]
    val == "tasks"
}

nodes { # docker nodes (part of swarm)
	val := input.PathArr[_]
    val == "nodes"
}

secrets { # docker secrets (part of swarm)
	val := input.PathArr[_]
    val == "secrets"
}

configs { # docker config (part of swarm)
	val := input.PathArr[_]
    val == "configs"
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

capadd { # allow CapAdd == null or CapAdd == [] (empty array)
    input.Body.HostConfig.CapAdd != null 
    not capadd_array
}

capadd_array {
    is_array(input.Body.HostConfig.CapAdd)
    count(input.Body.HostConfig.CapAdd) == 0
}

devices { #only null and empty arrays are allowed
    input.Body.HostConfig.Devices != null
    not devices_array
} 

devices_array {
    is_array(input.Body.HostConfig.Devices)
    count(input.Body.HostConfig.Devices) == 0 
}

ipc { #only string values "none", "private" and "" are allowed
    not is_string(input.Body.HostConfig.IpcMode)
} {
    input.Body.HostConfig.IpcMode != "none"
    input.Body.HostConfig.IpcMode != "private"
    input.Body.HostConfig.IpcMode != ""
} 

network { #any string values except "host" and "bridge" are allowed
    not is_string(input.Body.HostConfig.NetworkMode)
} {
    input.Body.HostConfig.NetworkMode == "host"
} {
    input.Body.HostConfig.NetworkMode == "bridge"
}

pid { #only string values "" are allowed
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
    input.Body.HostConfig.Privileged
} 

seccomp_apparmor_unconfined {
    contains(input.Body.HostConfig.SecurityOpt[_], "unconfined")
}