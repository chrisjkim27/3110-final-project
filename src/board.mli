(** Representation of Chess board

    This module represents the 8 x 8 chess board with chess pieces in
    it. This modules provides functions to update the board or flip the
    board and allows printing of the board to show the board in a clean
    and clear way.*)

type t
(**The abstract type representing an 8 x 8 chess board. *)

type grid = int * int
(**Represents the location of a Chess piece as a tuple (row,column).
   [(0,0)] is the top left grid on the board and [(7,7)] is the bottom
   right grid. *)

val init_board : unit -> t
(**[init_board ()] is the initial chess board with only pawns on either
   side of the board (in their normal position). *)

val move_piece : t -> grid -> grid -> t
(** [move_piece board ori_loc new_loc] is an updated board with the
    piece at [ori_loc] moved to location [new_loc]. The location
    [ori_loc] is set to an empty grid (no piece on it).*)

val flip : t -> t
(**[flip b] is a reversed board [b] so that the top is now the bottom,
   and vice versa. It also reverses the contents of rows, so [flip b] is
   essentially the same as if you rotated the board 180 degrees. *)

val print_board : t -> unit
(** [print_board b] prints the board as a series of strings. *)

val get_str_piece : t -> grid -> string
(**[to_piece b l] is the piece (represented as a string) at location [l]
   in board [b].*)

val get_row : t -> int -> string list
(**[get_row b r] is a list of the pieces (represented as strings) of row
   [r] in board [b] in the order that they appear in [r] (left to
   right).*)
