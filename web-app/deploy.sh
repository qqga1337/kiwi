#!/bin/bash
echo "Зпустили deploy.sh"
cd ~/app
docker-compose --project-name=app stop
docker-compose --project-name=app up -d
echo "APP loaded"
