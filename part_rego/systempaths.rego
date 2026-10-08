package docker.authz

allow {
    not systempaths
}

systempaths { # docker masks /proc/kcore, /proc/keys, /sys/firmware, ... and mounts /proc/sys,
              # /proc/sysrq-trigger, ... read-only. An empty array turns that off. Writable
              # /proc/sys means writable kernel.core_pattern, which is a host escape.
              # docker cli sends null here, so any explicit value is forbidden.
              # NOTE: `--security-opt systempaths=unconfined` is translated by the cli into empty
              # MaskedPaths/ReadonlyPaths, so a SecurityOpt rule does not catch it.
    input.Body.HostConfig.MaskedPaths != null
} {
    input.Body.HostConfig.ReadonlyPaths != null
}
