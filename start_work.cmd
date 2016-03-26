@echo off
rem AUTOMATIC COFFEESCRIPT COMPILATION FROM SOURCE AND TEST DIRECTORIES IS STARTED

start coffee -m -o src/main/webapp -c -w src/main/coffeescript
