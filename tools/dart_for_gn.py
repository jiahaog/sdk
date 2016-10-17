#!/usr/bin/env python
# Copyright 2016 The Dart project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Usage: dart_for_gn.py path_to_dart_binary [arguments]
#
# We have gn set up so that actions can only run python scripts.
# We use this wrapper script when we need an action to run the Dart VM
# The first command line argument is mandatory and should be the absolute path
# to the Dart VM binary.

import subprocess
import sys

def main(argv):
  if len(argv) < 2:
    print "Requires path to Dart VM binary as first argument"
    return -1
  command = argv[1:]
  return subprocess.call(command)

if __name__ == '__main__':
    sys.exit(main(sys.argv))
