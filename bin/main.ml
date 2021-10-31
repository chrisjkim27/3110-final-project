open Chess
open Board
open State
open Pieces

(* To play type "make play" in terminal once navigating to root
   directory.*)

(* ====================START HELPER FUNCTIONS======================== *)
(* ================================================================== *)

(*Converts str version of tuple to a regular tuple. Example: ["(3,5)"
  becomes (3,5)]. *)
let str_to_grid str =
  (int_of_char str.[1] - 48, int_of_char str.[3] - 48)

(*Converts regular version of tuple to a string. Example: [(3,5) becomes
  "(3,5)"]. *)
let grid_to_str grid =
  "(" ^ string_of_int (fst grid) ^ "," ^ string_of_int (snd grid) ^ ")"

(* ======================================================= *)

(* [get_dest brd state sel_pce_loc] is the valid destination location
   that the user wants to move their selected piece to. This function
   calls is_legal and is_path_empty to determine if the selected piece
   is able to move to the dest location the player inputs. If illegal
   move, player is prompted for a different dest location, and this
   repeats until valid dest is inputted.*)
let rec get_dest state sel_pce_loc =
  let dest = read_line () |> str_to_grid in
  let select_piece = what_piece state sel_pce_loc in
  let pce_on_dest = what_piece state dest in

  match
    is_legal select_piece pce_on_dest
    && is_path_empty state sel_pce_loc dest
  with
  | true -> dest
  | false ->
      let () =
        print_endline
          "Your selected piece cannot move to that location. Input a \
           new destination location."
      in
      get_dest state sel_pce_loc

(* ======================================================= *)

(* [get_select_pce_loc state] is the location of the piece that the
   player wants to select. If player selects a location without a piece,
   this function keeps asking for a board location until the user inputs
   a location with a piece on it.*)
let rec get_select_pce_loc state =
  let input = read_line () |> str_to_grid in
  match what_piece state input with
  | exception InvalidLocation e ->
      let () =
        print_endline
          "Not valid board location. Input another location.";
        print_string ">"
      in
      get_select_pce_loc state
  | p -> (
      let piece = p in
      match is_piece piece with
      | true -> input
      | false ->
          let () =
            print_endline
              "Not a piece. Input location of piece you want to select.";
            print_string ">"
          in
          get_select_pce_loc state)
(* ========================================== *)

(* returns selected piece location *)
let select_piece st =
  (* Prompt player to select the piece they want to move by inputting
     the piece's location. *)
  let () =
    print_endline "";
    print_endline
      "Select piece you want to move by inputting its location in \
       EXACT format (row,column). Upper left is (0,0) and bottom right \
       is (7,7). NO SPACES!";
    print_string ">"
  in

  (* Get the location of the piece player wants to move. If location has
     no piece, keep asking until player inputs location with piece. *)
  get_select_pce_loc st

(* ============================================ *)

(* gets piece on destination grid*)
let rec get_pce_on_dest state dest =
  match what_piece state dest with
  | exception InvalidLocation e ->
      let () =
        print_endline
          "Not valid board location. Input another location.";
        print_string ">"
      in
      let dest = read_line () |> str_to_grid in
      get_pce_on_dest state dest
  | p -> p

(* ============================ *)

let rec get_dest_ex brd state sel_pce_loc =
  (* Prompt for destination location. *)
  let () =
    print_endline "";
    print_endline
      ("CURRENTLY SELECTED PIECE: "
      ^ get_str_piece brd sel_pce_loc
      ^ " at " ^ grid_to_str sel_pce_loc)
  in
  let () =
    print_endline
      "Input destination location in EXACT format (row,column). Upper \
       left is (0,0) and bottom right is (7,7). NO SPACES!";
    print_string ">"
  in
  let dest = read_line () in
  (* if dest is not a location, then reassign sel_pce_loc *)
  match dest with
  | "reselect" -> get_dest_ex brd state (select_piece state)
  | x -> (
      let dest = x |> str_to_grid in
      let select_piece = what_piece state sel_pce_loc in
      let pce_on_dest = get_pce_on_dest state dest in
      match
        is_legal select_piece pce_on_dest
        && is_path_empty state sel_pce_loc dest
      with
      | true -> [ sel_pce_loc; dest ]
      | false ->
          let () =
            (* Do I need to factor out each part I want to loop over and
               over again to helper functions? *)
            print_endline "";
            print_endline
              "Your selected piece cannot move to that location. Input \
               a new destination location."
          in
          get_dest_ex brd state sel_pce_loc)

(* ================================================ *)

(* Return list [starting location; destination loc] *)
let rec get_input_dest brd st =
  (* Get the location of the piece player wants to move. If location has
     no piece, keep asking until player inputs location with piece. *)
  let select_pce_loc = select_piece st in

  (* Get the destination location - ask player for dest location; check
     to see if the selected piece can be legally moved from starting to
     dest location; if not, keep asking for a dest location until a
     valid dest location for the selected piece is inputted.*)
  get_dest_ex brd st select_pce_loc

(* ================================================================== *)
(* =======================END HELPER FUNCTIONS======================= *)

(* THE MAIN FUNCTION FOR GAMEPLAY. *)
let rec play_game brd st =
  (* Print current board *)
  let () = print_endline "Current board:" in
  let () = print_board brd in

  (* Get [input location;destination location] in list form let *)
  let input_dest = get_input_dest brd st in

  (* get starting position out of list *)
  let select_pce_loc = List.hd input_dest in

  (* get dest location out of list *)
  let dest = input_dest |> List.tl |> List.hd in

  (* Move the piece the player selected to position dest. *)
  let brd = move_piece brd select_pce_loc dest in

  (* Get the moved piece and mark it as having moved at least once. *)
  let moved_piece = what_piece st select_pce_loc |> first_move in

  (* Update the state so it reflects the updated board. There needs to
     be 2 function calls to fully update state after a move. The first
     call to update_loc connects the dest location to moved_piece in the
     assoc list. The second call to update_loc puts a None piece on the
     original spot of moved_piece. *)
  let st = update_loc st dest moved_piece in
  let st =
    update_loc st select_pce_loc (to_piece select_pce_loc "[ ]")
  in

  (* Tell player that move is complete and print the updated board. *)
  let () = print_endline "Move complete:" in
  let () = print_board brd in

  (* COULD CALL A FUNCTION AT THIS POINT TO CHECK FOR CHECKMATE. IF
     CHECKMATE, THEN THE GAME WOULD STOP AND A WINNER WOULD BE PRINTED
     OUT AT THIS POINT. *)

  (* "Flip" board orientation so opposing player can read board easily.
     Print this board out. In addition, the state must be "flipped" to
     accurately reflect what piece is on which board location.*)
  let brd = flip brd in
  let st = flip_state st in
  let () = print_endline "" in
  let () = print_endline "Next player - board flipped: " in
  let () = print_board brd in

  (* Ask if players want to keep playing. *)
  let () =
    print_endline "";
    print_endline "Keep playing? y or n"
  in
  let keep_play = read_line () |> String.lowercase_ascii in
  if keep_play = "y" then
    (*If players want to continue, call play_game with the current board
      and state.*)
    play_game brd st
    (*If players want to stop, print a end of game message and allow
      play_game to terminate. *)
  else print_endline "Goodbye!"

(* ================================================================== *)

let main () =
  ANSITerminal.print_string [ ANSITerminal.blue ]
    "\n\nWelcome to Extremely Simple Chess.\n";
  let board = init_board () in
  let st = init_state board in
  play_game board st

(* Starts game. *)
let () = main ()

(*CODE ABOVE DOES NOT HANDLE WINNING THE GAME. *)

let check_castle state (p : piece) (p2 : piece) =
  if is_king p && abs (snd (get_position p) - snd (get_position p2)) > 1
  then
    let p3 = castle_side state p2 in
    if is_path_empty state (get_position p) (get_position p3) then
      can_castle p p3
    else false
  else false
