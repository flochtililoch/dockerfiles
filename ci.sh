#!/bin/bash

if [ $TRAVIS_BRANCH == "fix-ci" ] && [ $TRAVIS_PULL_REQUEST == "false" ]; then
  # prepare environment
  docker run --rm --privileged multiarch/qemu-user-static:register --reset
  docker login -u="$DOCKER_USER" -p="$DOCKER_PASS"

  # get changed images
  IMAGES=$(git diff --name-only $TRAVIS_COMMIT_RANGE | grep images/ | grep Dockerfile)

  if [ ! -z $IMAGES ]; then

    echo "Building images"
    echo "==============="

    # for each image
    cd images
    for IMAGE in "${IMAGES[@]}"
    do
      IMAGE_PATH=$(echo $IMAGE | tr "/" "\n")
      IMAGE_ARRAY=(${IMAGE_PATH//;/ })
      IMAGE_NAME=${IMAGE_ARRAY[1]}
      PLATFORM=${IMAGE_ARRAY[2]}

      echo "Building $IMAGE_NAME for platform $PLATFORM"
      echo "#./build.sh $IMAGE_NAME $PLATFORM"
      
      TAG=$(grep "ENV VERSION" ../$IMAGE | awk 'NF>1{print $NF}')
      if [ ! -z $TAG ]; then
        echo "Tagging $IMAGE_NAME for platform $PLATFORM with tag $TAG"
        echo "#./tag.sh $IMAGE_NAME $TAG $PLATFORM"

        echo "Pushing $IMAGE_NAME for platform $PLATFORM with tag $TAG"
        echo "#./push.sh $IMAGE_NAME $TAG $PLATFORM"
      fi
      echo "Tagging $IMAGE_NAME for platform $PLATFORM with tag latest"
      echo "#./tag.sh $IMAGE_NAME latest $PLATFORM"

      echo "Pushing $IMAGE_NAME for platform $PLATFORM with tag latest"
      echo "#./push.sh $IMAGE_NAME latest $PLATFORM"
    done
    cd ..

  fi

  # get changed images references
  IMAGES=$(git diff --name-only $TRAVIS_COMMIT_RANGE | grep images/ | grep ref)
  if [ ! -z $IMAGES ]; then

    echo "Cloning images"
    echo "==============="

    # for each image reference
    cd images
    for IMAGE in "${IMAGES[@]}"
    do
      IMAGE_PATH=$(echo $IMAGE | tr "/" "\n")
      IMAGE_ARRAY=(${IMAGE_PATH//;/ })
      IMAGE_NAME=${IMAGE_ARRAY[1]}
      PLATFORM=${IMAGE_ARRAY[2]}
      TAG=latest
      echo "Cloning $IMAGE_NAME for platform $PLATFORM with tag $TAG"
      echo "#./clone.sh $IMAGE_NAME $TAG $PLATFORM"
    done
    cd ..

  fi

fi
