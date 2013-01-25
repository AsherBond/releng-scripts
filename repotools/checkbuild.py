#!/usr/bin/env python

import sys
import requests
import json


URL_TEMPL = "http://jenkins.release.eucalyptus-systems.com:8080/view/QA/job/qa-enterprise-%s-centos-6-kvm-tgt/api/json?pretty=true"
JOB_VERSIONS = {
	"maint/3.2/testing": "3.2-testing",
	"testing": "testing",
}

if __name__ == "__main__":
    try:
        if len(sys.argv) < 2:
             print "Must provide branch name"
             sys.exit(1)
        url = URL_TEMPL % (JOB_VERSIONS[sys.argv[1]])
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

