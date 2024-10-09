
public abstract class Piece {
	
	private boolean isWhite;
	public boolean killed = false;
	private String name;
	
	
	
	public Piece(boolean w) {
		
		isWhite    = w;
	}
	
	public Piece(boolean iW, String n, Position p) {
		
		name       = n;
		isWhite = iW;
	}

	public boolean isSameColor(Piece p) {
		if(p == null) {
			return false;
		}
		if(this.isWhite() && p.isWhite() || !this.isWhite() && !p.isWhite()) {
			return true;
		}
		return false;
	}
	
	
	public abstract boolean canMove(Board board, 
            Position start, Position end);
	
	public boolean isWhite() {
		return isWhite;
	}

	public void setWhite(boolean isWhite) {
		this.isWhite = isWhite;
	}

	public boolean isKilled()
	{
		return this.killed;
	}
	  
	public void setKilled(boolean killed)
	{
		this.killed = killed;
	}
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	

}
