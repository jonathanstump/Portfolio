package ChessPackage;

public class Queen extends Piece {
	
	public Queen(boolean iW) {
		//white on bottom
		super(iW);
		
			if(iW == false) {
				this.setWhite(false);
			}
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
							!b.getPosition(start.getRank(), i).equals(end)) {
						return false;
					}
				}
			}
			if(start.getFile() > end.getFile()) {
				for(int i = start.getFile()-1; i >= end.getFile(); i--) {
					if(b.getPosition(start.getRank(),i).isOccupied() && 
							!b.getPosition(start.getRank(), i).equals(end)) {
						return false;
					}
				}
			}
			return true;
		}
		//check vertical
		if(start.getFile() == end.getFile() && start.getRank() != end.getRank()) {
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
		//check diagonal
		if((Math.abs(start.getFile() - end.getFile())) == (Math.abs(start.getRank() - end.getRank()))) {
			int x = start.getFile();
			//check if going down
			if(start.getRank() < end.getRank()) {
				//check if going down to the left 
				if(start.getFile() > end.getFile()) {
					for(int i = start.getRank()+x; i <= end.getRank(); i++){
						x--;
						if(b.getPosition(i,x).isOccupied() && 
								!b.getPosition(i, x).equals(end)){
							return false;
						}
						
					}
				}
				//checks if going down to the right
				else {
					for(int i = start.getRank()+1; i <= end.getRank(); i++){
						x++;
						if(b.getPosition(i,x).isOccupied() && 
								!b.getPosition(i,x).equals(end)){
							return false;
						}
						
					}
				}
			}
			//check if going up
			else
			{	
				//check if going up to the left
				if(start.getFile() > end.getFile()) {
					for(int i = start.getRank()-1; i >= end.getRank(); i--){
						x--;
						if(b.getPosition(i, x).isOccupied() && 
								!b.getPosition(i, x).equals(end)){
							return false;
						}
						
					}
				}
				//checks if going up to the right
				else {
					for(int i = start.getRank()-1; i > end.getRank(); i--){
						x++;
						if(b.getPosition(i, x).isOccupied() && 
								!b.getPosition(i,x).equals(end)){
							System.out.println(b.getPosition(i, x));
							return false;
						}
					}
				}
			}
			return true;
		}
		
		return false;
	}
	
	public String toString() {
		return super.toString();
	}
}
