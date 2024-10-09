package ChessPackage;

public class Pawn extends Piece {
	public boolean promotion = false;
	public boolean firstMove = true;
	public Pawn(boolean iW) {
		super(iW);

		if(!iW) {
			this.setWhite(false);
		}
	}

	public boolean getFirstMove() {
		return firstMove;
	}
	public void setFirstMove(boolean f) {
		firstMove = f;
	}

	public boolean canMove(Board b, Position start, Position end) {
		if( end.getPiece() != null) {
			if(end.getPiece().isSameColor(start.getPiece())) {

				return false;
			}
		}
		//for black pawns
		if(!this.isWhite()) {
			//check if can move forward twice
			if(start.getFile() == end.getFile() && firstMove && end.getRank() == start.getRank() + 2 || ((end.getRank() == start.getRank() + 1 )&& end.getFile() == start.getFile()))
			{
				if(b.getPosition(end.getRank(), end.getFile()).isOccupied()) {
					return false;
				}
				return true;
			}
			if(end.getRank() == start.getRank() +1) {
				if(b.getPosition(end.getRank(), end.getFile()).isOccupied())
				{
					if(start.getFile()==7)
					{
						if(b.getPosition(start.getRank() + 1 , start.getFile() -1).equals(end))
						{
							return true;
						}
					}
					else if(start.getFile()==0)
					{
						if(b.getPosition(start.getRank() + 1 , start.getFile() +1).equals(end))
						{
							return true;
						}
						
					}
					else if((b.getPosition(start.getRank() + 1 , start.getFile() +1).equals(end)) ||
						    (b.getPosition(start.getRank() + 1 , start.getFile() -1).equals(end))) 
					{
						return true;
					}
					return false;
				}
				else
				{
					if(start.getFile() == end.getFile() && Math.abs(start.getFile() - end.getFile()) == 1)
					{
						return true;
					}
					return false;
				}
			}
			
			

			return false;
		}
		//for white pawns
		else {
			if(b.getPosition(end.getRank(), end.getFile()).isOccupied())
			{
				if(start.getFile()==7)
				{
					if(b.getPosition(start.getRank() - 1 , start.getFile() -1).equals(end))
					{
						return true;
					}
				}
				else if(start.getFile()==0)
				{
					if(b.getPosition(start.getRank() - 1 , start.getFile() +1).equals(end))
					{
						return true;
					}
					
				}
				else if((b.getPosition(start.getRank() - 1 , start.getFile() +1).equals(end)) ||
					    (b.getPosition(start.getRank() - 1 , start.getFile() -1).equals(end))) 
				{
					return true;
				}
			}
			else {
				if((!firstMove) && (start.getFile() == end.getFile()) && (Math.abs(start.getRank() - end.getRank()) == 1))
				{
					return true;
				}
				if(!firstMove) {
					return false;
				}
			}
			//check if can move forward twice
			if((start.getFile() == end.getFile() && firstMove && end.getRank() == start.getRank() - 2) || (start.getFile() == end.getFile() && end.getRank() == start.getRank() - 1 ))
			{
				if(b.getPosition(end.getRank(), end.getFile()).isOccupied()) {
					return false;
				}
				return true;
			}
//			if(!firstMove && end.getRank() == start.getRank() -1) {
//				if(b.getPosition(end.getRank(), end.getFile()).isOccupied()) {
//					return false;
//				}
//				return true;
//			}


			return false;
		}
	}
	

}

