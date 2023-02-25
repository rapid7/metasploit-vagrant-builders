#!/bin/bash

open /private/tmp/Install_macOS_11.7.4-20G1120.dmg
until [ -d /Volumes/Install\ macOS\ Big\ Sur ]
do
  sleep 5
done
/Volumes/Install\ macOS\ Big\ Sur/Install\ macOS\ Big\ Sur.app/Contents/Resources/startosinstall --agreetolicense --nointeraction --forcequitapps
