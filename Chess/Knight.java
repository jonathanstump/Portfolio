
public class Knight extends Piece{
	public Knight(boolean iW) {
		super(iW);
		
		if(!iW) {
			this.setWhite(false);
		}
	}
	
	public boolean canMove(Board b, Position start, Position end) {
		if( end.getPiece() != null) {
			if(end.getPiece().isSameColor(start.getPiece())) {
		
				return false;
			}
		}

		int x = Math.abs(start.getFile() - end.getFile());
        int y = Math.abs(start.getRank() - end.getRank());
        return x * y == 2;
	
		
	}

}
