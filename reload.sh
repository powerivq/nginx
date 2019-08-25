#!/bin/bash

while true
do
  echo "Sleeping..."
  nginx -s reload
  sleep 86400
done
