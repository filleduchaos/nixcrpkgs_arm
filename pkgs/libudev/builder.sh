source $setup

tar -xf $src
mv systemd-* systemd

cd systemd
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
cd ..

size_flags="-DSIZEOF_PID_T=4 -DSIZEOF_UID_T=4 -DSIZEOF_GID_T=4 \
-DSIZEOF_TIME_T=4 -DSIZEOF_RLIM_T=8 -DSIZEOF_INO_T=8 -DSIZEOF_DEV_T=8"
$host-g++ -x c++ -c $size_flags - -o test.o <<EOF
#include <type_traits>
#include <sys/types.h>
#include <sys/resource.h>
static_assert(sizeof(pid_t) == SIZEOF_PID_T);
static_assert(sizeof(uid_t) == SIZEOF_UID_T);
static_assert(sizeof(gid_t) == SIZEOF_GID_T);
static_assert(sizeof(time_t) == SIZEOF_TIME_T);
static_assert(sizeof(rlim_t) == SIZEOF_RLIM_T);
static_assert(sizeof(dev_t) == SIZEOF_DEV_T);
static_assert(sizeof(ino_t) == SIZEOF_INO_T);
EOF

CFLAGS="-Werror -DHAVE_DECL_SETNS -D_GNU_SOURCE $size_flags"

rm test.o

mkdir build
cd build

# -DHAVE_SECURE_GETENV: We don't have secure_getenv but we want to avoid a header error,
# and hopefully secure_getenv isn't actually needed by libudev.

$host-gcc -c -Werror -I$fill $fill/*.c
$host-gcc -c $CFLAGS \
  -I../systemd/src/libudev \
  -I../systemd/src/basic \
  -I../systemd/src/libsystemd/sd-device \
  -I../systemd/src/libsystemd/sd-hwdb \
  -I../systemd/src/systemd \
  ../systemd/src/libudev/*.c
$host-gcc -c $CFLAGS \
  -I../systemd/src/libsystemd/sd-device \
  -I../systemd/src/basic \
  -I../systemd/src/systemd \
  ../systemd/src/libsystemd/sd-device/{device-enumerator,device-private,sd-device}.c
$host-gcc -c $CFLAGS \
  -DPACKAGE_STRING="\"libudev $version\"" \
  -DFALLBACK_HOSTNAME="\"localhost\"" \
  -DDEFAULT_HIERARCHY_NAME="\"hybrid\"" \
  -DDEFAULT_HIERARCHY=CGROUP_UNIFIED_SYSTEMD \
  -I../systemd/src/basic \
  -I../systemd/src/systemd \
  -I$fill \
  ../systemd/src/basic/{alloc-util,architecture,bus-label,cgroup-util,dirent-util,env-util,escape,extract-word,fd-util,fileio,fs-util,gunicode,glob-util,hashmap,hash-funcs,hexdecoct,hostname-util,io-util,log,login-util,mempool,mkdir,path-util,proc-cmdline,parse-util,prioq,process-util,random-util,signal-util,siphash24,socket-util,stat-util,string-table,string-util,strv,strxcpyx,syslog-util,terminal-util,time-util,unit-name,user-util,utf8,util,virt}.c
$host-ar cr libudev.a *.o

mkdir -p $out/lib/pkgconfig $out/include
cp libudev.a $out/lib/
cp ../systemd/src/libudev/libudev.h $out/include/

cat > $out/lib/pkgconfig/libudev.pc <<EOF
prefix=$out
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: libudev
Version: $version
Libs: -L\${libdir} -ludev -ludev -ludev
Cflags: -I\${includedir}
EOF
