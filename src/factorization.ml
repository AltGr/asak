(* This file is part of asak.
 *
 * Copyright (C) 2019 IRIF / OCaml Software Foundation.
 *
 * asak is distributed under the terms of the MIT license. See the
 * included LICENSE file for details. *)

open Monad_error
open Err
open Utils

open Parse_structure

let load_file f =
  let ic = open_in f in
  let n = in_channel_length ic in
  let s = really_input_string ic n in
  close_in ic;
  s

let find_name = function
  | Lambda.Llet (_,_,n,_,_) -> Ident.name n
  | _ -> "noname"

let add_name pref x = pref ^ "/" ^ find_name x

let split_sequence_with hard_weight t =
  let threshold = Lambda_utils.Hard hard_weight in
  let hash x =
    let (x,xs) = Lambda_utils.hash_lambda false threshold x in
    x::xs in
  let rec aux = function
    | Lambda.Lsequence (x,u) -> (add_name t x, hash x) :: aux u
    | x -> [add_name t x, hash x]
  in aux

let parse_all_implementations hard_weight files_list =
  let pred (lib,filename) =
    let pretty_filename = last @@ String.split_on_char '/' filename in
    parsetree_of_string (load_file filename)
    >>= type_with_init ~to_open:lib
    >>= fun r ->
    ret @@
      split_sequence_with hard_weight (lib ^ "." ^ pretty_filename) @@
        lambda_of_typedtree r
  in List.concat @@ filter_rev_map pred files_list

let search hard_weight files_list =
  let all_hashs = parse_all_implementations hard_weight files_list in
  Clustering.cluster all_hashs
