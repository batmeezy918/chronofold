cmake_minimum_required(VERSION 3.10)

add_library(apollo SHARED apollo.cpp)

find_library(log-lib log)

target_link_libraries(apollo ${log-lib})
