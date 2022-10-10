package docker.authz

allow {
	not plugins
}

plugins {
	val := input.PathArr[_]
    val == "plugins"
}

