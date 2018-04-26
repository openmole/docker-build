#!/bin/sh

cd build-system/
sbt publishLocal
cd ../libraries
sbt publishLocal
cd ../openmole
sbt "project openmole" assemble

