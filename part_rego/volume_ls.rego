package docker.authz

allow {
    not volumes_ls
}

volumes_ls {
	input.Method == "GET"
    count(input.PathArr) == 3
    input.PathArr[2] == "volumes"
}