open Async
open Core

type t = (string * int)

let count_lines_in_string s =
  String.count s ~f:(fun c -> c = '\n')
;;

let count_lines_in_file path =
  Reader.file_contents path
  >>| count_lines_in_string
;;

let count_lines path =
  count_lines_in_file path >>| (fun count -> (path, count))
;;

let to_string (path, count) root =
  let punned_path = Str.replace_first (Str.regexp_string root) "" path in
  sprintf "%10d %s" count punned_path
;;

let compare (_, count1) (_, count2) =
  compare_int count1 count2
;;

let count = snd
;;
