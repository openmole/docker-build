# docker-build

This projects build OpenMOLE, and create a start-to-run docker environment. To use it:

```
docker build . -t openmole:latest
docker run --name openmole -p 8443:8443 -e UID=1000 -e GID=1000 openmole:latest 
```
