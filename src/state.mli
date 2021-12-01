(** Represents the state of the chess game.

    The module represents the state of a chess game. *)

type t
(** Abstract type representing state of a chess game. State includes
    what piece is on a grid in the board.*)

exception InvalidLocation of (int * int)

val init_state : Board.t -> t
(** [get_state b] is the state of board [b]. *)

val what_piece : t -> int * int -> Pieces.piece
(**[what_piece st l] is the piece at location [l] in state [st]. Raises
   [InvalidLocation l] if [l] is not in the board. *)

val update_loc : t -> int * int -> Pieces.piece -> t
(** [update_loc st l p] is state [st] updated so that the piece at
    location [l] is piece [p]. If there is a piece that was already at
    location [l], that piece is replaced by the new piece.*)

val is_path_empty : t -> int * int -> int * int -> bool
(**[is_path_empty st l1 l2] is true if path from location [l1] to [l2]
   on the chess board has no pieces, false otherwise. *)

val flip_state : t -> t
(**[flip_state st] is st but with the locations of pieces updated so
   that the state reflects the flipped board. *)

val castle_side : t -> Pieces.piece -> Pieces.piece
(**[is_path_empty st p2] returns the piece on the side that king wantst
   to castle where the rook would be at the start of the game *)

val in_check : t -> Pieces.piece -> bool
(**[in_check st p] returns [true] if the king is in check *)

val find_king : t -> string -> int * int
(** [fing_king st c] is the location of the king with color [c] in state
    [st]. Colors are "W", "B", or "N" (no color).*)

val promotion : t -> Pieces.piece -> int * int -> bool
(**[promotion st p pdest] is true if p is a [Pawn] and it is moved to
   the first row*)
