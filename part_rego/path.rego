package docker.authz

allow {
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