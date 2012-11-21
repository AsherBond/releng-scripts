#!/usr/bin/env python

import sys
import requests
import json

url = "http://jenkins.release.eucalyptus-systems.com:8080/view/QA/job/qa-enterprise-testing-centos-6-kvm-tgt/api/json?pretty=true"

if __name__ == "__main__":
    try:
        data = requests.get(url).text
        build = json.loads(data)["lastSuccessfulBuild"]
        build_data = requests.get(build["url"] + "api/json?pretty=true").text
        build = json.loads(build_data)
        for pair in build["actions"][0]["parameters"]:
            if pair["name"] == "commit":
                print pair["value"]
                sys.exit(0)
    except:
        sys.exit(1)

