
public class Rook extends Piece {

	private boolean firstMove = true;
	public Rook(boolean iW) {
		super(iW);

		if(iW == false) {
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

		//check horizontal
		if(start.getRank() == end.getRank() && start.getFile() != end.getFile()) {
			if(start.getFile() < end.getFile()) {
				for(int i = start.getFile()+ 1; i <= end.getFile(); i++) {
					if(b.getPosition(start.getRank(),i).isOccupied() && 
							!b.getPosition(i, start.getFile()).equals(end)) {
						return false;
					}
				}
			}
			if(start.getFile() > end.getFile()) {
				for(int i = start.getFile()-1; i >= end.getFile(); i--) {
					if(b.getPosition(start.getRank(),i).isOccupied() && 
							!b.getPosition(i, start.getFile()).equals(end)) {
						return false;
					}
				}
			}
			return true;
		}
		//check vertical
		if(start.getFile() == end.getFile() && start.getRank() != end.getFile()) {
			if(start.getRank() < end.getRank()) {
				for(int i = start.getRank()+ 1; i <= end.getRank(); i++) {
					if(b.getPosition(i,start.getFile()).isOccupied() && 
							!b.getPosition(i, start.getFile()).equals(end)) {
						return false;
					}
				}
			}
			if(start.getRank() > end.getRank()) {
				for(int i = start.getRank()-1; i >= end.getRank(); i--) {
					if(b.getPosition(i, start.getFile()).isOccupied() && 
							!b.getPosition(i, start.getFile()).equals(end)) {
						return false;
					}
				}
			}
			return true;
		}
		return false;
	}
}
