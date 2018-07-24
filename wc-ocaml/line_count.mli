open Async
open Core

(** A type representing a file and it's corresponding number of lines *)
type t

(** Constructs a Line_count.t *)
val count_lines : string -> t Deferred.t

(** Converts a Line_count.t to string, possibly punning to the current directory *)
val to_string : t -> string -> string

(** Returns the ordinality of two Line_count.t's *)
val compare : t -> t -> int

(** Returns the line count *)
val count : t -> int
