#!/usr/bin/env bash

if rfkill list bluetooth | grep -q "Soft blocked: no"; then
  rfkill block bluetooth
else
  rfkill unblock bluetooth
fi
