{ stdenv
, lib
, julia
, self
}:

let
  parseRequire = require:
  parseSystemDep (builtins.filter (t: t != "") (lib.splitString " " require));

  parseSystemDep = tokens:
  if tokens == [] then parseEnd {} else
  let token = builtins.head tokens; tokens' = builtins.tail tokens; in
  if token == "@unix"
  then parseSystemDep tokens'
  else if token == "@windows"
  then parseEnd {}
  else if token == "@linux"
  then if stdenv.isLinux
       then parseSystemDep tokens'
       else parseEnd {}
  else if token == "@osx"
  then if stdenv.isDarwin
       then parseSystemDep tokens'
       else parseEnd {}
  else if token == "@bsd"
  then if with stdenv; isFreeBSD || isOpenBSD || isDarwin
       then parseSystemDep tokens'
       else parseEnd {}
  else parsePackageName tokens;

  parsePackageName = tokens:
  if tokens == [] then parseEnd {} else
  let token = builtins.head tokens; tokens' = builtins.tail tokens; in
  parseEnd { pname = token; };  # do not parse version constraints for now

  parseEnd = state:
  if builtins.hasAttr "pname" state
  then if state.pname == "julia"
       then [ julia ]
       else [ (builtins.getAttr state.pname self) ]
  else [];

in

requires:

builtins.concatLists (map parseRequire requires)
