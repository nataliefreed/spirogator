#!/bin/bash

#This script cleans up Processing export a bit for distribution
#Removes source files from packaged applications for each platform
#(eliminates duplicate copies, keeps from confusing novice users)
#Renames packaged applications to something less general when downloaded separately


rm -r application.*/source
mv application.macosx spirogator.macosx
mv application.linux32 spirogator.linux32
mv application.linux64 spirogator.linux64
mv application.windows32 spirogator.windows32
mv application.windows64 spirogator.windows64



