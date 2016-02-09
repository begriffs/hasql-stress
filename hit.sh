patch() {
  curl -s 'http://localhost:3000'
}
export -f patch

THREADS=${1:-10}
seq $THREADS | parallel patch -j $THREADS
