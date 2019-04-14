install codeblocks with mingw package included
For ARPG proj or new interception projects

Settings -> Global compiler settings -> Compiler Settings -> Other compiler options
	add: --std=c++11
Settings -> Global compiler settings -> Linker Settings -> Other linker options
	add: -static -static-libgcc -static-libstdc++

Right-Click Project -> Properties -> Project's Build Options -> Search directories -> Linker
	add: ..\InterceptionDLL2\InterceptionDLL2\Debug
Right-Click Project -> Properties -> Project's Build Options -> Linker settings -> Link libraries
	add: ..\InterceptionDLL2\InterceptionDLL2\Debug\Interception.lib