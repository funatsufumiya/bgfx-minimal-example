local BUILD_DIR = path.join("build", _ACTION)
if _OPTIONS["cc"] ~= nil then
	BUILD_DIR = BUILD_DIR .. "_" .. _OPTIONS["cc"]
end
local BGFX_DIR = "bgfx"
local BIMG_DIR = "bimg"
local BX_DIR = "bx"
local GLFW_DIR = "glfw"

local BGFX_EXAMPLES = path.join("bgfx", "examples")
local BGFX_EXAMPLES_COMMON = path.join("bgfx", "examples", "common")
local BGFX_EXAMPLES_ASSETS = path.join("bgfx", "examples", "common")
local BGFX_EXAMPLES_RUNTIME = path.join("bgfx", "examples", "runtime")

local BGFX_3RDPARTY_DIR = path.join("bgfx", "3rdparty")

solution "bgfx-minimal-example"
	location(BUILD_DIR)
	startproject "helloworld"
	configurations { "Release", "Debug" }
	if os.istarget("macosx") and os.targetarch() == "arm64" then
		platforms "arm64"
	elseif os.is64bit() and not os.istarget("windows") then
		platforms "x86_64"
	else
		platforms { "x86", "x86_64" }
	end
	filter "configurations:Release"
		defines
		{
			"NDEBUG",
			"BX_CONFIG_DEBUG=0"
		}
		optimize "Full"
	filter "configurations:Debug*"
		defines
		{
			"_DEBUG",
			"BX_CONFIG_DEBUG=1"
		}
		optimize "Debug"
		symbols "On"
	filter "platforms:x86"
		architecture "x86"
	filter "platforms:x86_64"
		architecture "x86_64"
	filter "platforms:arm64"
		architecture "arm64"
	filter "system:macosx"
		xcodebuildsettings {
			["MACOSX_DEPLOYMENT_TARGET"] = "14.0",
			["ALWAYS_SEARCH_USER_PATHS"] = "YES", -- This is the minimum version of macos we'll be able to run on
		};

function setBxCompat()
	filter "action:vs*"
		includedirs { path.join(BX_DIR, "include/compat/msvc") }
	filter { "system:windows", "action:gmake" }
		includedirs { path.join(BX_DIR, "include/compat/mingw") }
	filter { "system:macosx" }
		includedirs { path.join(BX_DIR, "include/compat/osx") }
		buildoptions { "-x objective-c++" }
end

project "cubes"
	kind "ConsoleApp"
	language "C++"
	cppdialect "C++14"
	exceptionhandling "Off"
	rtti "Off"
	defines "ENTRY_CONFIG_USE_GLFW"
	defines "ENTRY_CONFIG_IMPLEMENT_MAIN"
	defines "ENTRY_IMPLEMENT_MAIN"
	files {
		path.join(BGFX_EXAMPLES, "01-cubes/cubes.cpp"),
		path.join(BGFX_3RDPARTY_DIR, "*.cpp"),
		path.join(BGFX_3RDPARTY_DIR, "dear-imgui/*.cpp"),
		path.join(BGFX_3RDPARTY_DIR, "meshoptimizer/src/*.cpp"),
		path.join(BGFX_EXAMPLES_COMMON, "*/*.cpp"),
		path.join(BGFX_EXAMPLES_COMMON, "*.cpp"),
	}
	excludes
	{
		path.join(BGFX_EXAMPLES_COMMON, "entry/entry_android.cpp"),
		path.join(BGFX_EXAMPLES_COMMON, "entry/entry_html5.cpp"),
		path.join(BGFX_EXAMPLES_COMMON, "entry/entry_noop.cpp"),
		path.join(BGFX_EXAMPLES_COMMON, "entry/entry_x11.cpp"),
		path.join(BGFX_EXAMPLES_COMMON, "entry/entry_sdl.cpp"),
		path.join(BGFX_EXAMPLES_COMMON, "entry/entry_windows.cpp"),
	}
	includedirs 
	{
		path.join(BGFX_EXAMPLES_COMMON),
		path.join(BGFX_3RDPARTY_DIR),
		path.join(BGFX_DIR, "include"),
		path.join(BX_DIR, "include"),
		path.join(BIMG_DIR, "include"),
		path.join(GLFW_DIR, "include")
	}
	filter "system:macosx"
		files {
			path.join(BGFX_EXAMPLES_COMMON, "entry/entry_osx.mm"),
		}
	links { "bgfx", "bimg", "bx", "glfw" }
	filter "system:windows"
		links { "gdi32", "kernel32", "psapi" }
	filter "system:linux"
		links { "dl", "GL", "pthread", "X11" }
	filter "system:macosx"
		links { "QuartzCore.framework", "Metal.framework", "Cocoa.framework", "IOKit.framework", "CoreVideo.framework" }
	setBxCompat()
	
project "helloworld"
	kind "ConsoleApp"
	language "C++"
	cppdialect "C++14"
	exceptionhandling "Off"
	rtti "Off"
	files "helloworld.cpp"
	includedirs
	{
		path.join(BGFX_DIR, "include"),
		path.join(BX_DIR, "include"),
		path.join(GLFW_DIR, "include")
	}
	links { "bgfx", "bimg", "bx", "glfw" }
	filter "system:windows"
		links { "gdi32", "kernel32", "psapi" }
	filter "system:linux"
		links { "dl", "GL", "pthread", "X11" }
	filter "system:macosx"
		links { "QuartzCore.framework", "Metal.framework", "Cocoa.framework", "IOKit.framework", "CoreVideo.framework" }
	setBxCompat()

project "helloworld_mt"
	kind "ConsoleApp"
	language "C++"
	cppdialect "C++14"
	exceptionhandling "Off"
	rtti "Off"
	files "helloworld_mt.cpp"
	includedirs
	{
		path.join(BGFX_DIR, "include"),
		path.join(BX_DIR, "include"),
		path.join(GLFW_DIR, "include")
	}
	links { "bgfx", "bimg", "bx", "glfw" }
	filter "system:windows"
		links { "gdi32", "kernel32", "psapi" }
	filter "system:linux"
		links { "dl", "GL", "pthread", "X11" }
	filter "system:macosx"
		links { "QuartzCore.framework", "Metal.framework", "Cocoa.framework", "IOKit.framework", "CoreVideo.framework" }
	setBxCompat()
	
project "bgfx"
	kind "StaticLib"
	language "C++"
	cppdialect "C++14"
	exceptionhandling "Off"
	rtti "Off"
	defines "__STDC_FORMAT_MACROS"
	files
	{
		path.join(BGFX_DIR, "include/bgfx/**.h"),
		path.join(BGFX_DIR, "src/*.cpp"),
		path.join(BGFX_DIR, "src/*.h"),
	}
	excludes
	{
		path.join(BGFX_DIR, "src/amalgamated.cpp"),
	}
	includedirs
	{
		path.join(BX_DIR, "include"),
		path.join(BIMG_DIR, "include"),
		path.join(BGFX_DIR, "include"),
		path.join(BGFX_DIR, "3rdparty"),
		path.join(BGFX_DIR, "3rdparty/dxsdk/include"),
		path.join(BGFX_DIR, "3rdparty/khronos")
	}
	filter "action:vs*"
		defines "_CRT_SECURE_NO_WARNINGS"
		excludes
		{
			path.join(BGFX_DIR, "src/glcontext_glx.cpp"),
			path.join(BGFX_DIR, "src/glcontext_egl.cpp")
		}
	filter "system:macosx"
		files
		{
			path.join(BGFX_DIR, "src/*.mm"),
		}
	setBxCompat()

project "bimg"
	kind "StaticLib"
	language "C++"
	cppdialect "C++14"
	exceptionhandling "Off"
	rtti "Off"
	files
	{
		path.join(BIMG_DIR, "include/bimg/*.h"),
		path.join(BIMG_DIR, "src/*.cpp"),
		path.join(BIMG_DIR, "src/*.h"),
		path.join(BIMG_DIR, "3rdparty/astc-codec/src/decoder/*.cc"),
		path.join(BIMG_DIR, "3rdparty/tinyexr/deps/miniz/miniz.c"),
	}
	includedirs
	{
		path.join(BX_DIR, "include"),
		path.join(BIMG_DIR, "include"),
		path.join(BIMG_DIR, "3rdparty"),
		path.join(BIMG_DIR, "3rdparty/iqa/include"),
		path.join(BIMG_DIR, "3rdparty/tinyexr/deps/miniz"),
		path.join(BIMG_DIR, "3rdparty/astc-codec"),
		path.join(BIMG_DIR, "3rdparty/astc-codec/include"),
	}
	setBxCompat()

project "bx"
	kind "StaticLib"
	language "C++"
	cppdialect "C++14"
	exceptionhandling "Off"
	rtti "Off"
	defines "__STDC_FORMAT_MACROS"
	files
	{
		path.join(BX_DIR, "include/bx/*.h"),
		path.join(BX_DIR, "include/bx/inline/*.inl"),
		path.join(BX_DIR, "src/*.cpp")
	}
	excludes
	{
		path.join(BX_DIR, "src/amalgamated.cpp"),
		path.join(BX_DIR, "src/crtnone.cpp")
	}
	includedirs
	{
		path.join(BX_DIR, "3rdparty"),
		path.join(BX_DIR, "include")
	}
	filter "configurations:Release"
		defines "BX_CONFIG_DEBUG=0"
	filter "configurations:Debug"
		defines "BX_CONFIG_DEBUG=1"
	filter "action:vs*"
		defines "_CRT_SECURE_NO_WARNINGS"
	setBxCompat()
		
project "glfw"
	kind "StaticLib"
	language "C"
	files
	{
		path.join(GLFW_DIR, "include/GLFW/*.h"),
		path.join(GLFW_DIR, "src/context.c"),
		path.join(GLFW_DIR, "src/egl_context.*"),
		path.join(GLFW_DIR, "src/init.c"),
		path.join(GLFW_DIR, "src/input.c"),
		path.join(GLFW_DIR, "src/internal.h"),
		path.join(GLFW_DIR, "src/monitor.c"),
		path.join(GLFW_DIR, "src/null*.*"),
		path.join(GLFW_DIR, "src/osmesa_context.*"),
		path.join(GLFW_DIR, "src/platform.c"),
		path.join(GLFW_DIR, "src/vulkan.c"),
		path.join(GLFW_DIR, "src/window.c"),
	}
	includedirs { path.join(GLFW_DIR, "include") }
	filter "system:windows"
		defines "_GLFW_WIN32"
		files
		{
			path.join(GLFW_DIR, "src/win32_*.*"),
			path.join(GLFW_DIR, "src/wgl_context.*")
		}
	filter "system:linux"
		defines "_GLFW_X11"
		files
		{
			path.join(GLFW_DIR, "src/glx_context.*"),
			path.join(GLFW_DIR, "src/linux*.*"),
			path.join(GLFW_DIR, "src/posix*.*"),
			path.join(GLFW_DIR, "src/x11*.*"),
			path.join(GLFW_DIR, "src/xkb*.*")
		}
	filter "system:macosx"
		defines "_GLFW_COCOA"
		files
		{
			path.join(GLFW_DIR, "src/cocoa_*.*"),
			path.join(GLFW_DIR, "src/posix_thread.h"),
			path.join(GLFW_DIR, "src/posix_module.h"),
			path.join(GLFW_DIR, "src/nsgl_context.h"),
			path.join(GLFW_DIR, "src/egl_context.h"),
			path.join(GLFW_DIR, "src/osmesa_context.h"),

			path.join(GLFW_DIR, "src/posix_thread.c"),
			path.join(GLFW_DIR, "src/posix_module.c"),
			path.join(GLFW_DIR, "src/nsgl_context.m"),
			path.join(GLFW_DIR, "src/egl_context.c"),
			path.join(GLFW_DIR, "src/nsgl_context.m"),
			path.join(GLFW_DIR, "src/osmesa_context.c"),                       
		}

	filter "action:vs*"
		defines "_CRT_SECURE_NO_WARNINGS"
