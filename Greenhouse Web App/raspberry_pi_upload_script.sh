#!/bin/bash
SCHOOL_ID="school123"
WEEK="34"
IMAGE="cam/latest.jpg"

curl -X POST http://your-vps-ip/api/images/upload \
  -F "schoolId=$SCHOOL_ID" \
  -F "week=$WEEK" \
  -F "image=@$IMAGE"
