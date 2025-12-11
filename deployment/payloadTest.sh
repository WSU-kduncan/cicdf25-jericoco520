#!/bin/bash
# payloadTest.sh - Test script for webhook
# Author: Jerico Corneja
#
# This script tests the webhook by sending a request to the local host.
# 
# Referece: Claude
#
# Prompt: How should I test the webhook?
#
# Response: You can test the webhook by sending a request to the local host.
# 
# I then created this script to just run it 
# A small change

# Test the webhook
curl -X POST http://44.216.103.86:9000/hooks/deploy-coffee-website \
  -H "Content-Type: application/json" \
  -d '{
    "push_data": {
      "tag": "latest",
      "pusher": "jericoco520"
    },
    "repository": {
      "repo_name": "jericoco520/p4-coffee-website",
      "namespace": "jericoco520",
      "name": "p4-coffee-website"
    }
  }'