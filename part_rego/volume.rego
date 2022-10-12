package docker.authz

allow {
    not volume
}

volume { # allow only simple volumes. No options allowed. DriverOpts is null or empty object.
    input.Body.DriverOpts != null 
    not driveropts_empty_object
}

driveropts_empty_object {
    is_object(input.Body.DriverOpts)
    count(input.Body.DriverOpts) == 0
}