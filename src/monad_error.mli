(* This file is part of asak.
 *
 * Copyright (C) 2019 Alexandre Moine.
 *
 * asak is distributed under the terms of the MIT license. See the
 * included LICENSE file for details. *)

val maybe : 'b -> ('a -> 'b) -> 'a option -> 'b

module Err : sig
  type 'a t

  val fail : 'a t
  val ret : 'a -> 'a t

  val map : ('a -> 'b) -> 'a t -> 'b t
  val ( >>= ) : 'a t -> ('a -> 'b t) -> 'b t

  val run : 'a t -> 'a option
  val to_err : 'a option -> 'a t
end
