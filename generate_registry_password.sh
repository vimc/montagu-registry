#!/usr/bin/env bash
vault write secret/registry/vimc password=$(pwgen -n1 80)
