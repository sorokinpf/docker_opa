# TODO

Только утверждённые криты: поля `HostConfig`, через которые обходятся уже принятые запреты.
Все пункты реализованы в `all.rego`, примеры — в `part_rego`, входы для проверки — в `bad_json`.
Синтаксис старый (pre-1.0), проверено на OPA 0.70.0.

Дефолты проверены по `bad_json/*` (docker CLI 20.10): `MaskedPaths`, `ReadonlyPaths`,
`DeviceCgroupRules`, `VolumesFrom` приезжают как `null`, а `Mounts`, `Capabilities`, `Sysctls`
при пустом значении не сериализуются вовсе. Правила ниже на обычных запросах молчат.

## [x] 1. `Mounts` — обход `binds` и `volume`

```
docker run --mount type=bind,src=/,dst=/mnt ubuntu
docker run --mount type=volume,dst=/mnt,volume-opt=type=none,volume-opt=device=/,volume-opt=o=bind
```

Второй вариант обходит заодно `volume`: оно смотрит на `Body.DriverOpts`, а не на
`Mounts[_].VolumeOptions.DriverConfig.Options`.

```rego
mounts { # only null / absent / empty array allowed
    input.Body.HostConfig.Mounts != null
    not mounts_empty_array
}

mounts_empty_array {
    is_array(input.Body.HostConfig.Mounts)
    count(input.Body.HostConfig.Mounts) == 0
}
```

Если `--mount` в пайплайнах используется — вместо этого гранулярно: разрешить `Type == "tmpfs"`
и `Type == "volume"` без `VolumeOptions.DriverConfig`, остальное deny.

## [x] 2. `Capabilities` — возможный обход `capadd`

Отдельное поле (API 1.40), «итоговый список» вместо `CapAdd`/`CapDrop`. Правило `capadd` смотрит
только на `CapAdd`, поэтому `{"CapAdd": null, "Capabilities": ["CAP_SYS_ADMIN"]}` проходит.
Honor'ит ли его наш демон — проверить; правило дешёвое в любом случае.

```rego
capabilities {
    input.Body.HostConfig.Capabilities != null
    not capabilities_empty_array
}

capabilities_empty_array {
    is_array(input.Body.HostConfig.Capabilities)
    count(input.Body.HostConfig.Capabilities) == 0
}
```

## [x] 3. `MaskedPaths` / `ReadonlyPaths` — побег на хост

Присланный `[]` снимает дефолтную маскировку `/proc` и `/sys`. Главное — `ReadonlyPaths`:
с записью в `/proc/sys` контейнерный root пишет `kernel.core_pattern` (глобальный, не namespaced)
и ядро хоста запускает его программу при падении процесса; проверки capability там нет.
Плюс `/proc/sysrq-trigger` — ребут/краш хоста.

Похоже, CLI транслирует `--security-opt systempaths=unconfined` именно в эти поля, а не в элемент
`SecurityOpt`, то есть текущее правило по подстроке `unconfined` его не ловит и это единственная
проверка. Любое явное значение запрещаем:

```rego
systempaths {
    input.Body.HostConfig.MaskedPaths != null
}

systempaths {
    input.Body.HostConfig.ReadonlyPaths != null
}
```

## [x] 4. `DeviceCgroupRules` — обход `devices`

`--device-cgroup-rule "b *:* rwm"` + `CAP_MKNOD` (в дефолтном наборе Docker) = `mknod` внутри
контейнера и доступ к сырым дискам хоста.

```rego
device_cgroup_rules {
    input.Body.HostConfig.DeviceCgroupRules != null
    not device_cgroup_rules_empty_array
}

device_cgroup_rules_empty_array {
    is_array(input.Body.HostConfig.DeviceCgroupRules)
    count(input.Body.HostConfig.DeviceCgroupRules) == 0
}
```

## [x] 5. `VolumesFrom` — обход `binds`

`--volumes-from <container>` наследует все маунты указанного контейнера. Путей знать не надо,
нужен только ID из разрешённого `docker ps`. На хосте с раннером это его `docker.sock` и `/cache`.

```rego
volumes_from {
    input.Body.HostConfig.VolumesFrom != null
    not volumes_from_empty_array
}

volumes_from_empty_array {
    is_array(input.Body.HostConfig.VolumesFrom)
    count(input.Body.HostConfig.VolumesFrom) == 0
}
```

## [x] 6. `Sysctls` — на всякий случай

Прямого побега не видно: Docker пускает только namespaced sysctls (`net.*` в своём netns,
`kernel.sem`/`msg*`/`shm*`, `fs.mqueue.*` в своём IPC ns). Остаётся DoS по памяти через
`kernel.shmall`/`shmmax` и правка сети чужого netns. Запрещаем, потому что цена нулевая,
а набор namespaced-sysctls в новых ядрах расширяется.

```rego
sysctls {
    input.Body.HostConfig.Sysctls != null
    not sysctls_empty_object
}

sysctls_empty_object {
    is_object(input.Body.HostConfig.Sysctls)
    count(input.Body.HostConfig.Sysctls) == 0
}
```

## [x] 7. Подключить в `allow_full`

В список `all.rego:11-42` дописать: `not mounts`, `not capabilities`, `not systempaths`,
`not device_cgroup_rules`, `not volumes_from`, `not sysctls`. Правило без ссылки из `allow_full` —
мёртвый код (как сейчас `ports`, `stop`, `attach`, `logs`).

## [x] 8. `CgroupParent` — числился в README, но правила не было

`--cgroup-parent` указан в README в списке Forbidden с самого начала, а проверки не существовало
ни в `all.rego`, ни в `part_rego`. Разрешена только пустая строка (дефолтный cgroup), по образцу
правила `pid`. Фикстура — `bad_json/cgroup_parent_bad.json`.

Рядом остались непроверенными два поля того же семейства, в объём не входили:
`CgroupnsMode` (`--cgroupns=host`) и `Cgroup` (API-only, принимает `container:<id>` — вход
в cgroup чужого контейнера).

