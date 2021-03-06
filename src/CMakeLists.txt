# libtool versioning
# See http://sources.redhat.com/autobook/autobook/autobook_91.html#SEC91 for details

## increment if the interface has additions, changes, removals.
set(LT_CURRENT 21)

## increment any time the source changes; set 0 to if you increment CURRENT
set(LT_REVISION 0)

## increment if any interfaces have been added; set to 0
## if any interfaces have been changed or removed. removal has
## precedence over adding, so set to 0 if both happened.
set(LT_AGE 13)

math(EXPR LT_CURRENT_MINUS_AGE "${LT_CURRENT} - ${LT_AGE}")

set(SONAME ${LT_CURRENT_MINUS_AGE}.${LT_AGE}.${LT_REVISION})
set(SOVERSION ${LT_CURRENT_MINUS_AGE})

function(set_oscap_generic_properties TARGET_OBJECT)
	set_target_properties(${TARGET_OBJECT} PROPERTIES
		CXX_VISIBILITY_PRESET hidden    # Make global variables and functions HIDDEN by default.
		POSITION_INDEPENDENT_CODE ON    # Compile this object code position independent.
	)
	target_compile_definitions(${TARGET_OBJECT} PRIVATE OSCAP_BUILD_SHARED)
endfunction()

if(ENABLE_CCE)
	add_subdirectory("CCE")
endif()
add_subdirectory("common")
add_subdirectory("CPE")
add_subdirectory("CVE")
add_subdirectory("CVSS")
add_subdirectory("CVRF")
add_subdirectory("DS")
add_subdirectory("OVAL")
if(ENABLE_SCE)
	add_subdirectory("SCE")
endif()
add_subdirectory("source")
add_subdirectory("XCCDF")
add_subdirectory("XCCDF_POLICY")

set(OBJECTS_TO_LINK_AGAINST
	$<TARGET_OBJECTS:common_object>
	$<TARGET_OBJECTS:cpe_object>
	$<TARGET_OBJECTS:cve_object>
	$<TARGET_OBJECTS:cvrf_object>
	$<TARGET_OBJECTS:cvss_object>
	$<TARGET_OBJECTS:ds_object>
	$<TARGET_OBJECTS:oscapsource_object>
	$<TARGET_OBJECTS:oval_object>
	$<TARGET_OBJECTS:ovaladt_object>
	$<TARGET_OBJECTS:ovalcmp_object>
	$<TARGET_OBJECTS:ovalresults_object>
	$<TARGET_OBJECTS:rbt_object>
	$<TARGET_OBJECTS:xccdf_object>
	$<TARGET_OBJECTS:xccdfPolicy_object>
)
if (TARGET "compat_object")
	list(APPEND OBJECTS_TO_LINK_AGAINST $<TARGET_OBJECTS:compat_object>)
endif()
if (ENABLE_CCE)
	list(APPEND OBJECTS_TO_LINK_AGAINST $<TARGET_OBJECTS:cce_object>)
endif()
if (ENABLE_PROBES)
	list(APPEND OBJECTS_TO_LINK_AGAINST
		$<TARGET_OBJECTS:probe_object>
		$<TARGET_OBJECTS:seap_object>
	)
	if (ENABLE_PROBES_INDEPENDENT)
		list(APPEND OBJECTS_TO_LINK_AGAINST
			$<TARGET_OBJECTS:independent_probes_object>
		)
	endif()
	if (ENABLE_PROBES_UNIX)
		list(APPEND OBJECTS_TO_LINK_AGAINST
			$<TARGET_OBJECTS:unix_probes_object>
		)
		if (ENABLE_PROBES_LINUX)
			list(APPEND OBJECTS_TO_LINK_AGAINST
				$<TARGET_OBJECTS:linux_probes_object>
			)
		endif()
		if (ENABLE_PROBES_SOLARIS)
			list(APPEND OBJECTS_TO_LINK_AGAINST
				$<TARGET_OBJECTS:solaris_probes_object>
			)
		endif()
	endif()
	if (ENABLE_PROBES_WINDOWS)
		list(APPEND OBJECTS_TO_LINK_AGAINST
			$<TARGET_OBJECTS:windows_probes_object>
		)
	endif()
endif()
if (GCRYPT_FOUND OR NSS_FOUND)
	list(APPEND OBJECTS_TO_LINK_AGAINST
		$<TARGET_OBJECTS:crapi_object>
	)
endif()

add_library(openscap SHARED ${OBJECTS_TO_LINK_AGAINST})

# default symbol visibility is hidden
# exported symbols must be marked by OSCAP_API
set_target_properties(openscap PROPERTIES
	VERSION ${SONAME}
	SOVERSION ${SOVERSION}
	C_VISIBILITY_PRESET hidden
)

target_link_libraries(openscap ${LIBXML2_LIBRARIES} ${LIBXSLT_LIBRARIES} ${LIBXSLT_EXSLT_LIBRARIES} ${PCRE_LIBRARIES} ${CURL_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})
if (BZIP2_FOUND)
	target_link_libraries(openscap ${BZIP2_LIBRARIES})
endif()
if(RPM_FOUND)
	target_link_libraries(openscap ${RPM_LIBRARIES})
endif()
if(WIN32)
	target_link_libraries(openscap wsock32 ws2_32 iphlpapi netapi32 wbemuuid)
endif()
if (GCRYPT_FOUND)
	target_link_libraries(openscap ${GCRYPT_LIBRARIES})
endif()
if (NSS_FOUND)
	target_link_libraries(openscap ${NSS_LIBRARIES})
endif()
if(OPENDBX_FOUND)
	target_link_libraries(openscap ${OPENDBX_LIBRARIES})
endif()
if(GCONF_FOUND)
	target_link_libraries(openscap ${GCONF_LIBRARIES})
endif()
if(SELINUX_FOUND)
	target_link_libraries(openscap ${SELINUX_LIBRARIES})
endif()
if(PROCPS_FOUND)
	target_link_libraries(openscap ${PROCPS_LIBRARIES})
endif()
if(BLKID_FOUND)
	target_link_libraries(openscap ${BLKID_LIBRARIES})
endif()
if(DBUS_FOUND)
	target_link_libraries(openscap ${DBUS_LIBRARIES})
endif()
if(APTPKG_FOUND)
	target_link_libraries(openscap ${APTPKG_LIBRARIES})
endif()
if(ACL_FOUND)
	target_link_libraries(openscap ${ACL_LIBRARY})
endif()

if(WIN32)
	set(OPENSCAP_INSTALL_DESTINATION ".")
else()
	set(OPENSCAP_INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR})
endif()

install(TARGETS openscap DESTINATION ${OPENSCAP_INSTALL_DESTINATION})
