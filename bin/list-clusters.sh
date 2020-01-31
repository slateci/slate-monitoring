#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

ls ../private/conf/*.conf | rev | cut -d/ -f1 | rev | cut -d. -f1
