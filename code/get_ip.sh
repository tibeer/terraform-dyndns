#!/bin/bash
echo "{\"ip\": \"$(curl -s $1 ifconfig.io)\""}
