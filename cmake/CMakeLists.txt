cmake_minimum_required(VERSION 3.2.2)
project(AirSim)

add_subdirectory("rpclib_wrapper")
add_subdirectory("AirLib")
add_subdirectory("MavLinkCom")
add_subdirectory("AirLibUnitTests")
add_subdirectory("DroneShell")
add_subdirectory("HelloDrone")
