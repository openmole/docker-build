#!/bin/sh

(
  cd openmole &&
  git fetch &&
  git submodule init &&
  git submodule update &&
  git lfs fetch &&

  git checkout v10.1 &&

  (cd build-system && sbt clean publishLocal) &&
  (cd libraries && sbt clean publishLocal) &&
  (cd openmole && sbt clean publishLocal) &&
  (cd openmole && sbt "project openmole" assemble)
)
