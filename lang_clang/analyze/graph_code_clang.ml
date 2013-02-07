(* Yoann Padioleau
 *
 * Copyright (C) 2013 Facebook
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 * 
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
 *)
open Common

module E = Database_code
module G = Graph_code

open Ast_clang
module Ast = Ast_clang

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(*
 * Graph of dependencies for Clang ASTs. See graph_code.ml and
 * main_codegraph.ml for more information.
 * 
 * 
 * schema:
 *)

(*****************************************************************************)
(* Types *)
(*****************************************************************************)
(* for the extract_uses visitor *)

type env = {
  g: Graph_code.graph;
  phase: phase;

  current: Graph_code.node;
}
 and phase = Defs | Uses


(*****************************************************************************)
(* Parsing *)
(*****************************************************************************)

(*****************************************************************************)
(* Add Node *)
(*****************************************************************************)

(*****************************************************************************)
(* Add edge *)
(*****************************************************************************)

(*****************************************************************************)
(* Defs/Uses *)
(*****************************************************************************)


(* ---------------------------------------------------------------------- *)
(* Toplevels *)
(* ---------------------------------------------------------------------- *)

(* ---------------------------------------------------------------------- *)
(* Stmt *)
(* ---------------------------------------------------------------------- *)

(* ---------------------------------------------------------------------- *)
(* Expr *)
(* ---------------------------------------------------------------------- *)

(* ---------------------------------------------------------------------- *)
(* Types *)
(* ---------------------------------------------------------------------- *)

(* ---------------------------------------------------------------------- *)
(* Misc *)
(* ---------------------------------------------------------------------- *)

(*****************************************************************************)
(* Main entry point *)
(*****************************************************************************)

let build ?(verbose=true) dir skip_list =
  raise Todo
