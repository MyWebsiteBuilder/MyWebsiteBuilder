#!/usr/bin/env bash

set -euo pipefail

build() {

  local src="$1"
  local dst="$2"

  if [[ -f "$src".html ]]; then

    mkdir -p "${dst%/*}"/

    if [[ "${MODE:-development}" == production ]]; then

      npx ejs "$src".html -o "$dst".html -m "!" -w

    else

      npx ejs "$src".html -o "$dst".html -m "!"

    fi

  fi

  if [[ -f "$src".css ]]; then

    mkdir -p "${dst%/*}"/

    if [[ "${MODE:-development}" == production ]]; then

      npx lightningcss "$src".css -o "$dst".css --bundle --browserslist --minify

    else

      npx lightningcss "$src".css -o "$dst".css --bundle --browserslist

    fi

  fi

  if [[ -f "$src".js ]]; then

    mkdir -p "${dst%/*}"/

    npx rolldown "$src".js -o "$dst".combined.js -f iife

    npx swc "$dst".combined.js -o "$dst".transpiled.js -q

    if [[ "${MODE:-development}" == production ]]; then

      npx rolldown "$dst".transpiled.js -o "$dst".js -m

    else

      cp "$dst".transpiled.js "$dst".js

    fi

    rm "$dst".combined.js
    rm "$dst".transpiled.js

  fi

  if [[ -f "${src%/*}"/Handler.java ]]; then

    mkdir -p "${dst%/*}"/

    if [[ "${MODE:-development}" == production ]]; then

      javac -cp "dst/lib/*" "${src%/*}"/Handler.java -d "${dst%/*}"/

    else

      javac -cp "dst/lib/*" "${src%/*}"/Handler.java -d "${dst%/*}"/ -g

    fi

    local args=(-C "${dst%/*}"/ Handler.class)

    if [[ -d "${src%/*}"/resources/ ]]; then

      args+=(-C "${src%/*}"/ resources/)

    fi

    if [[ -f "$dst".html ]]; then
    
      args+=(-C "${dst%/*}"/ "${dst##*/}".html)

    fi

    jar cf "$dst".jar "${args[@]}"

    rm "${dst%/*}"/Handler.class

    rm -f "$dst".html

  fi

}

