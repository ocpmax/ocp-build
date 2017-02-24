(**************************************************************************)
(*                                                                        *)
(*   Typerex Tools                                                        *)
(*                                                                        *)
(*   Copyright 2011-2017 OCamlPro SAS                                     *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU General Public License version 3 described in the file       *)
(*   LICENSE.                                                             *)
(*                                                                        *)
(**************************************************************************)

open StringCompat

open BuildEngineTypes


type package_type = BuildOCPTypes.package_type =
  | ProgramPackage
  | TestPackage
  | LibraryPackage
  | ObjectsPackage
  | SyntaxPackage
  | RulesPackage


type 'a package_dependency = 'a BuildOCPTypes.package_dependency =
    {
      dep_project : 'a;
      mutable dep_link : bool;
      mutable dep_syntax : bool;
      mutable dep_optional : bool;
      dep_options : BuildValue.TYPES.env;
    }

type package_info = {
  lib_context : BuildEngineTypes.build_context;
  lib_id : int;
  lib_name : string;
  lib_builder_context : builder_context;

  lib_loc : string * int * string;
  (*  mutable lib_options : BuildValue.TYPES.env; *)

  (*  mutable lib_version : string; *)
  mutable lib_dirname : File.t;
  mutable lib_provides : string;
  mutable lib_type : BuildOCPTypes.package_type;
  mutable lib_tag : string;

  (* true means that it should be ignored about objects *)
  lib_filename : string;
  lib_source_kind : string;

  (*  lib_plugin : exn; *)
  lib_node : LinearToposort.node;

  (*  mutable lib_requires : package_info list; *)
  mutable lib_added : bool;
  lib_src_dir : BuildEngineTypes.build_directory;
  lib_dst_dir : BuildEngineTypes.build_directory;
  lib_mut_dir : BuildEngineTypes.build_directory;

  (* [lib_bundles] specifies the other packages that should be
     uninstalled when this package is uninstalled.

     The field is initialized when installing packages, from the
      "bundle" variables of packages being installed.
  *)
  mutable lib_bundles : package_info list;
}


and builder_context = {
  build_context : build_context;
  mutable packages_by_name : package_info StringMap.t;
  all_projects : (int, package_info) Hashtbl.t;
  config_filename_validated_table : (string, build_file) Hashtbl.t;
  uniq_rules : (string, build_rule) Hashtbl.t;
}


type targets = {
  targets : BuildEngineTypes.build_file list;
  depends : package_info list;
}

module type Plugin = sig
  val name : string
end

(* A package, as exported by a plugin *)

module type Package = sig
  val name: string
  val info : package_info
  val plugin : (module Plugin)

  val conf_targets : unit -> targets
  val build_targets : unit -> targets
  val doc_targets : unit -> targets
  val test_targets : unit -> targets

  (* all files generated by this package *)
  val clean_targets : unit -> BuildEngineTypes.build_file list

  val test : unit -> (unit -> unit) option
  val pre_installed : unit -> bool
  val install : unit -> unit
  val to_install : unit -> bool

  (* Where to find the uninstaller *)
  val install_dirs : unit -> string list
end
