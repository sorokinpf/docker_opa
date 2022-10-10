package docker.authz

allow {
    not devices
}

devices { #only null and empty arrays are allowed
    input.Body.HostConfig.Devices != null
    not devices_array
} 

devices_array {
    is_array(input.Body.HostConfig.Devices)
    count(input.Body.HostConfig.Devices) == 0 
}