package ChessPackage;

public class King extends Piece {
	//public boolean checkMate = false;
	private boolean firstMove = true;
		public King(boolean iW) {
			super(iW);
			
			if(!iW) {
				this.setWhite(false);
			}
		}
		
		public boolean getFM() {
	        return firstMove; // Getter for firstMove
	    }

	    public void setFM(boolean hasMoved) {
	        this.firstMove = hasMoved; // Setter for firstMove
	    }
		
		public boolean canMove(Board b, Position start, Position end) {
			if( end.getPiece() != null) {
				if(end.getPiece().isSameColor(start.getPiece()))  {
			
					return false;
				}
			}

			int x = Math.abs(start.getFile() - end.getFile());
	        int y = Math.abs(start.getRank() - end.getRank());
	        
	        if(y==0)
	        {
	        	if(x==1)
	        	{
	        		return true;
	        	}
	        	return false;
	        }
	        
	        if(x==0)
	        {
	        	if(y==1)
	        	{
	        		return true;
	        	}
	        	return false;
	        }
	        
	        if (x + y == 2) {
	        	return true;
	        }
	        return false;
		}
		
		/*
		 * checks if the kings next move will move to
		 */
		private boolean isFutureCheck(Board b, Position currP ,Position nextP) {
			
			for(int r = 0; r < b.getRows(); r++) {
				for(int c = 0; c < b.getCols(); c++) {
					if(b.getPosition(r,c).getPiece() != null && !b.getPosition(r,c).equals(currP)) {
						if(b.getPosition(r,c).getPiece().canMove(b, b.getPosition(r,c), nextP) && 
								!b.getPosition(r,c).getPiece().isSameColor(currP.getPiece())) {
							return true;
						}
					}
				}
			}
			
			return false;
		}
		
		/*
		 * checks if the king is currently checked
		 * currP is the king's current position
		 * possP is the position that possibly checks the king.
		 */
		public boolean isChecked(Board b, Position currP,Position possP) {
			if(possP.getPiece().canMove(b, possP, currP )) {
				return true;
			}
			return false;
		}

}
