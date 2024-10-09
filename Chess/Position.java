
public class Position {

	private int rank; // y
	private int file; // x
	private Piece piece;
	
	Position(int r, int f, Piece p){
		rank = r;
		file = f;
		piece = p;
	}
	
	public int getRank() {
		return rank;
	}
	
	public Piece getPiece() {
		return piece;
	}
	
	public void setPiece(Piece p) {
		piece = p;
	}
	
	public boolean isOccupied() {
        if(piece != null)
            return true;
        return false;
    }
	
	public void setRank(int y) {
		rank = y;
	}
	
	public int getFile() {
		return file;
	}
	
	public void setFile(int x) {
		file = x;
	}
	
	
	public boolean equals(Position otherPosition) {
		
		if((this.rank == otherPosition.rank) &&
		   (this.file == otherPosition.file)) {
			return true;
		}
		return false;
	}
	
	public String toString() {
		return "row= " +rank+ "column ="+file + "Piece: "+ piece;
	}
}
