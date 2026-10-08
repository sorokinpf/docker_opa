echo 'get plugins'
docker plugin ls
echo 'creating container for tests'
ID=$(docker run -d --rm ubuntu sleep 6000)
echo 'exec'
docker exec $ID bash
echo 'copy in'
echo 123 > test.data
docker cp test.data $ID:/tmp
rm test.data
echo 'copy out'
docker cp $ID:/etc/passwd .
echo 'export'
docker export $ID -o test
echo 'kill'
docker kill $ID
echo 'pause'
docker pause $ID
echo 'restart'
docker restart $ID
echo 'update'
docker update --cpus 2 $ID
echo 'commit'
docker commit $ID
echo 'events'
docker events
echo 'session'
echo 'not test for session'
echo 'swarm'
docker swarm init
echo 'services'
docker service ls
echo 'tasks'
echo 'not test for tasks'
echo 'nodes'
docker node ls
echo 'secrets'
docker secret ls
echo 'configs'
docker config ls
echo 'volume ls'
docker volume ls
echo 'volume create bad'
docker volume create --name my_test_volume --opt type=none --opt device=/ --opt o=bind
echo 'volume create allowed'
VOL_ID=$(docker volume create test_volume)
echo $VOL_ID
echo 'binds (volumes) bad'
docker run --rm -v /:/app ubuntu whoami
echo 'binds (volumes) allowed'
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ubuntu whoami
echo 'binds (volumes) allowed'
docker run --rm -v test_volume:/volume ubuntu whoami
echo 'capadd'
docker run --cap-add SYS_ADMIN ubuntu whoami
echo 'devices'
docker run --device /dev/vda1 ubuntu whoami
echo 'device cgroup rule (--device bypass, needs CAP_MKNOD which is on by default)'
docker run --rm --device-cgroup-rule 'b *:* rwm' ubuntu whoami
echo 'cgroup parent'
docker run --rm --cgroup-parent=/evil ubuntu whoami
echo 'mounts bad (-v bypass)'
docker run --rm --mount type=bind,src=/,dst=/mnt ubuntu whoami
echo 'mounts bad 2 (volume driver opts, bypasses volume create rule too)'
docker run --rm --mount type=volume,dst=/mnt,volume-opt=type=none,volume-opt=device=/,volume-opt=o=bind ubuntu whoami
echo 'volumes-from (-v bypass)'
docker run --rm --volumes-from $ID ubuntu whoami
echo 'systempaths (unmasks /proc and /sys, cli sends it as empty MaskedPaths/ReadonlyPaths)'
docker run --rm --security-opt systempaths=unconfined ubuntu whoami
echo 'sysctl'
docker run --rm --sysctl kernel.shmall=4294967296 ubuntu whoami
echo 'capabilities (no cli flag for it, api only)'
curl -s --unix-socket /var/run/docker.sock -H 'Content-Type: application/json' \
  -X POST 'http://d/v1.41/containers/create' \
  -d '{"Image":"ubuntu","Cmd":["whoami"],"HostConfig":{"Capabilities":["CAP_SYS_ADMIN"]}}'
echo
echo 'ipc'
docker run --ipc=privatefew ubuntu whoami
echo 'network 2 tests'
docker run --network=host ubuntu whoami
docker run --network=bridge ubuntu whoami
echo 'pid'
docker run --pid=host ubuntu whoami
echo 'ports'
docker run -p 3333:3333 ubuntu whoami
echo 'privileged'
docker run --privileged ubuntu whoami
echo 'seccomp'
docker run --security-opt seccomp=unconfined ubuntu whoami
echo 'apparmor'
docker run --security-opt apparmor:unconfined ubuntu whoami
echo 'clearing up'
docker stop $ID
docker volume rm $VOL_ID