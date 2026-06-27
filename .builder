#!/usr/bin/env bash

set -euo pipefail

build() {

  local srcdir="$1"
  local name="$2"
  local dstdir="$3"

  if [[ -f "${srcdir}${name}".html ]]; then

    if [[ "${MODE:-development}" == "production" ]]; then

      npx ejs "${srcdir}${name}".html -o "${dstdir}${name}".html -m ! -w

    else

      npx ejs "${srcdir}${name}".html -o "${dstdir}${name}".html -m !

    fi

  fi

  if [[ -f "${srcdir}${name}".css ]]; then

    if [[ "${MODE:-development}" == "production" ]]; then

      npx lightningcss "${srcdir}${name}".css -o "${dstdir}${name}".css --bundle --browserslist --minify

    else

      npx lightningcss "${srcdir}${name}".css -o "${dstdir}${name}".css --bundle --browserslist

    fi

  fi

  if [[ -f "${srcdir}${name}".js ]]; then

    npx rolldown "${srcdir}${name}".js -o "${dstdir}${name}".combined.js -f iife

    npx swc "${dstdir}${name}".combined.js -o "${dstdir}${name}".transpiled.js -q

    if [[ "${MODE:-development}" == "production" ]]; then

      npx rolldown "${dstdir}${name}".transpiled.js -o "${dstdir}${name}".js -m

    else

      cp "${dstdir}${name}".transpiled.js "${dstdir}${name}".js

    fi

    rm "${dstdir}${name}".combined.js
    rm "${dstdir}${name}".transpiled.js

  fi

  if [[ -f "$srcdir"Handler.java ]]; then

    true

  fi

}

