#!/usr/bin/env python3
import json
import subprocess
import sys

def get_tf_outputs():
    cmd = ["terraform", "output", "-json"]
    result = subprocess.run(cmd, cwd="terraform/environments/dev", capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error getting Terraform outputs: {result.stderr}", file=sys.stderr)
        sys.exit(1)
    return json.loads(result.stdout)

if __name__ == "__main__":
    outputs = get_tf_outputs()
    print(json.dumps(outputs, indent=2))