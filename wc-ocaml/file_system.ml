open Core
open Async

let is_file path =
  Sys.is_file path >>| (fun answ ->
      match answ with
      | `Yes -> true
      | `No | `Unknown -> false
    )
;;

let ls_dir path =
  Sys.ls_dir path
  >>| List.map ~f:(fun f -> Filename.concat path f)
  >>= (fun l -> Deferred.all (List.map l ~f:(fun f -> (is_file f) >>| (fun answ -> (f, answ)))))
  >>| List.filter ~f:snd
  >>| List.map ~f:fst
;;
