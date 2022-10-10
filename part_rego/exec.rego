package docker.authz

allow {
	not exec
}

exec {
	val := input.PathArr[_]
    val == "exec"
}

