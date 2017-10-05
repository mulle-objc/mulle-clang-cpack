#! /bin/sh

VERSION=5.0.0.1
DIST=`lsb_release -sc`

verify()
{
   cd cpack-mulle-clang

   if ! fgrep "${VERSION}" cpack-mulle-clang/CMakeLists.txt
   then
      echo "cpack-mulle-clang has the wrong version" >&2
      exit 1
   fi
  
   cd ..
}


clean()
{
   rm -rf mulle-clang-lldb
   mkdir mulle-clang-lldb
}


download()
{
   cd mulle-clang-lldb
   curl -L -O "https://raw.githubusercontent.com/Codeon-GmbH/mulle-clang/mulle_objclang_50/install-mulle-clang.sh"
   chmod 755 install-mulle-clang.sh 
   cd ..
}


build()
{
   cd mulle-clang-lldb
   mkdir -p opt/mulle-clang/${VERSION}
   ./install-mulle-clang.sh --prefix `pwd`/opt/mulle-clang/${VERSION} --with-lldb
   cd ..
}


verpack()
{
   cp cpack-mulle-clang/* mulle-clang-lldb/

   cd mulle-clang-lldb
   chmod 755 generate-package.sh 
   ./generate-package.sh 
   cd ..
}

upload()
{
   scp mulle-clang-lldb/package/mulle-clang-${VERSION}-Linux.deb oswald:debian-software/dists/${DIST}/main/binary-amd64/mulle-clang-${VERSION}-${DIST}-amd64.deb
} 


main()
{
   while [ $# -ne 0 ]
   do
      "$1"
      shift
   done
}

set -x

if [ $# -eq 0 ]
then
   main verify clean build verpack upload
else
   main "$@"
fi

