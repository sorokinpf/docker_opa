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
echo 'binds (volumes)'
docker run -v $(pwd):/app ubuntu ls
echo 'capadd'
docker run --cap-add SYS_ADMIN ubuntu ls
echo 'devices'
docker run --device /dev/vda1 ubuntu ls
echo 'ipc'
docker run --ipc=privatefew ubuntu ls
echo 'network 2 tests'
docker run --network=host ubuntu ls
docker run --network=bridge ubuntu ls
echo 'pid'
docker run --pid=host ubuntu ls
echo 'ports'
docker run -p 3333:3333 ubuntu ls
echo 'privileged'
docker run --privileged ubuntu ls
echo 'seccomp'
docker run --security-opt seccomp=unconfined ubuntu ls
echo 'apparmor'
docker run --security-opt apparmor:unconfined ubuntu ls
echo 'stopping test container'
docker stop $ID