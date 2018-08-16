# RtAudio

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  include(FindPkgConfig)
  pkg_check_modules(JACK "jack")
  pkg_check_modules(PULSEAUDIO "libpulse-simple")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  find_library(COREAUDIO_LIBRARY "CoreAudio")
endif()
find_package(Threads REQUIRED)

add_library(RtAudio STATIC "${RtAudio_SOURCE_DIR}/RtAudio.cpp")
target_include_directories(RtAudio PUBLIC "${RtAudio_SOURCE_DIR}")
target_link_libraries(RtAudio PUBLIC "${CMAKE_THREAD_LIBS_INIT}")
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_compile_definitions(RtAudio PUBLIC "__LINUX_ALSA__")
  target_link_libraries(RtAudio PUBLIC "asound")
  if(JACK_FOUND)
    target_compile_definitions(RtAudio PUBLIC "__UNIX_JACK__")
    target_include_directories(RtAudio PUBLIC ${JACK_INCLUDE_DIRS})
    link_directories(${JACK_LIBRARY_DIRS})
    target_link_libraries(RtAudio PUBLIC ${JACK_LIBRARIES})
  endif()
  if(PULSEAUDIO_FOUND)
    target_compile_definitions(RtAudio PUBLIC "__LINUX_PULSE__")
    target_include_directories(RtAudio PUBLIC ${PULSEAUDIO_INCLUDE_DIRS})
    link_directories(${PULSEAUDIO_LIBRARY_DIRS})
    target_link_libraries(RtAudio PUBLIC ${PULSEAUDIO_LIBRARIES})
  endif()
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  target_link_libraries(RtAudio PUBLIC "winmm")
  target_compile_definitions(RtAudio PUBLIC "__WINDOWS_DS__")
  target_link_libraries(RtAudio PUBLIC "dsound" "ole32")
  target_compile_definitions(RtAudio PUBLIC "__WINDOWS_WASAPI__")
  target_link_libraries(RtAudio PUBLIC "ksguid")
  target_compile_definitions(RtAudio PUBLIC "__WINDOWS_ASIO__")
  target_include_directories(RtAudio PRIVATE
    "${RtAudio_SOURCE_DIR}/include")
  target_sources(RtAudio PRIVATE
    "${RtAudio_SOURCE_DIR}/include/asio.cpp"
    "${RtAudio_SOURCE_DIR}/include/asiodrivers.cpp"
    "${RtAudio_SOURCE_DIR}/include/asiolist.cpp"
    "${RtAudio_SOURCE_DIR}/include/iasiothiscallresolver.cpp")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  target_compile_definitions(RtAudio PUBLIC "__MACOSX_CORE__")
  target_link_libraries(RtAudio PUBLIC "${COREAUDIO_LIBRARY}")
endif()
