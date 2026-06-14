# Clean generated simulation files.
Remove-Item -Recurse -Force work -ErrorAction SilentlyContinue
Remove-Item -Force transcript -ErrorAction SilentlyContinue
Remove-Item -Force vsim.wlf -ErrorAction SilentlyContinue
Remove-Item -Force modelsim.ini -ErrorAction SilentlyContinue
Remove-Item -Force *.log -ErrorAction SilentlyContinue
