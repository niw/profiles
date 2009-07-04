" MacPorts Portfile syntax
" $Id: macports.vim 621 2007-11-02 15:40:55Z kimuraw $

" includes Tcl syntax
runtime! syntax/tcl.vim

" default Portfile style
set tabstop=4
set shiftwidth=4

" enable '.' as a keyword character
set iskeyword+=.

" portfile(7) keywords
sy keyword portPortSystem	PortSystem PortGroup
sy keyword portMainVariables	name version epoch description long_description revision categories maintainers platforms homepage master_sites worksrcdir distname checksums use_automake use_autoconf use_configure
sy match portTargetHooks	"target\.\(dir\|env\|pre_args\|post_args\|args\)"
sy keyword portRuntimeVariables	prefix libpath portpath workpath worksrcpath filesdir filespath distpath os.arch os.version os.endian os.platform install.user install.group x11prefix
sy keyword portDependencyOpts	depends_build depends_run depends_lib
sy keyword portFetchOpts	master_sites.mirror_subdir patch_sites patch_sites.mirror_subdir extract.suffix distfiles patchfiles use_zip use_bzip2 dist_subdir
sy match portAdvFetchOpts	"\(fetch\.\(user\|password\|user_epsv\|ignore_sslcert\)\)\|\(cvs\.\(root\|tag\|date\|module\)\)\|\(svn\.\(url\|tag\)\)"
sy keyword portExtractOpts	extract.only extract.cmd
sy match portConfigureOpts	"configure\.\(cflags\|cppflags\|cxxflags\|ldflags\|cc\|cpp\|cxx\|fc\|f77\|f90\|compiler\)"
sy match portUniversalTargetHooks	"configure\.universal_\(args\|cflags\|cppflags\|cppflags\|cxxflags\|ldflags\)"
sy match portBuildOpts		"build\.\(cmd\|type\|target\)"
sy match portDestrootOpts	"destroot\.\(cmd\|type\|destdir\|target\|umask\|keepdirs\|violate_mtree\)"
sy match portTestOpts		"test\.\(run\|cmd\|target\)"
sy match portStartupItemOpts	"startupitem\.\(create\|type\|name\|executable\|init\|start\|stop\|restart\|pidfile\|logfile\|logevents\)"
sy match portDistCheckOpts	"distcheck\.check\|\(livecheck\.\(check\|name\|distname\|version\|url\|regex\|md5\)\)"
sy keyword portVariantOpts	variant default_variants universal_variant
sy keyword portPlatformOpts	platform

" colors
hi link portPortSystem		Statement
hi link portMainVariables	Statement
hi link portTargetHooks		Statement
hi link portRuntimeVariables	Identifier
hi link portDependencyOpts	Statement
hi link portFetchOpts		Statement
hi link portAdvFetchOpts	Statement
hi link portExtractOpts		Statement
hi link portConfigureOpts	Statement
hi link portUniversalTargetHooks	Statement
hi link portBuildOpts		Statement
hi link portDestrootOpts	Statement
hi link portTestOpts		Statement
hi link portStartupItemOpts	Statement
hi link portDistCheckOpts	Statement
hi link portVariantOpts		Statement
hi link portPlatformOpts	Statement

