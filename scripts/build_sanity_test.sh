#!/bin/bash
#
# Copyright (c) 2019, 2019 IBM Corporation and others.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Do a fresh build
./build.sh

# Terminate any previously running kruize docker images.
./deploy.sh -c docker -t

# Deploy the newly build kruize image
./deploy.sh -c docker -i kruize:$(cat .kruize-version) --timeout=60

# Get logs for current run
logs=$(docker logs kruize)

# Check if the recommendations are getting generated
echo "$logs" | grep "CPU Limit" > /dev/null
result=$?
if [ ${result} -ne 0 ]; then
	echo "$logs"
	echo
	echo "Kruize sanity test failed! CPU Limit not found in kruize docker logs!"
	exit 1
fi

# Make sure there are no errors
echo "$logs" | grep -i "error" > /dev/null
result=$?
if [ ${result} -ne 1 ]; then
	echo "$logs"
	echo
	echo "Kruize sanity test failed! Error found in kruize docker logs!"
	exit 1
fi

# Make sure there are no exceptions
echo "$logs" | grep -i "exception" > /dev/null
result=$?
if [ ${result} -ne 1 ]; then
	echo "$logs"
	echo
	echo "Kruize sanity test failed! Exception found in kruize docker logs!"
	exit 1
fi

echo "All tests passed!"
