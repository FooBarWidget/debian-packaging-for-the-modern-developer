# Tutorial 5: customizing debhelper behavior

Let's say you have an application that must be compiled in manner that debhelper doesn't support out-of-the-box. It could be a C application with a custom build system. Or it could be a Go application (debhelper doesn't support Go at the time of writing). What do you do? Do you fall back to not using debhelper as much, like you did in tutorial 3? There is a better way: you can override parts of debhelper while still allowing it to everything else.

apt install golang
