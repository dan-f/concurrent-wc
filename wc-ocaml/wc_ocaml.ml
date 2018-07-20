open Core
open Async

let get_line_counts_in_dir path =
  (* Sys.getcwd ()
     >>= fun cwd -> *)
  File_system.ls_dir path
  >>= Core.Fn.compose Deferred.all (List.map ~f:Line_count.count_lines)
;;

let print_total_thunk line_counts () =
  line_counts
  >>| List.fold ~init:0 ~f:(fun total line_count -> total + Line_count.count line_count)
  >>| printf "%10d [TOTAL]\n"
;;

let print_counts dir line_counts =
  line_counts
  >>| Core.Fn.compose List.rev (List.sort ~compare:Line_count.compare)
  >>= (fun line_counts ->
      Sys.getcwd ()
      >>| (fun cwd -> List.map ~f:(fun line_count -> Line_count.to_string line_count (cwd ^ "/")) line_counts))
  >>| List.fold ~init:() ~f:(fun _ s -> print_endline s)
  >>= print_total_thunk line_counts
;;

let () =
  let dir = match Sys.argv with
    | [| _; dir |] -> return dir
    | _ -> Sys.getcwd ()
  in
  let line_counts = dir >>= get_line_counts_in_dir in
  let task = print_counts dir line_counts in
  Deferred.upon task (fun () -> shutdown 0);
  never_returns (Scheduler.go ())
;;
