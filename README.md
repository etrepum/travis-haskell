Instructions:

```
sudo apt-get -y install git gcc make autoconf libtool zlib1g-dev \
  libncurses-dev libgmp-dev
if [ ! -e "/usr/lib/libgmp.so.3" ]; then
  sudo ln -s /usr/lib/x86_64-linux-gnu/libgmp.so.10 /usr/lib/libgmp.so.3
fi
if [ ! -e "/usr/lib/libgmp.so" ]; then
  sudo ln -s /usr/lib/x86_64-linux-gnu/libgmp.so.10 /usr/lib/libgmp.so
fi
# wget | tar 
```
