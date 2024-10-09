
package ChessPackage;

public class Bishop extends Piece{

	public Bishop(boolean iW) {
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
		//check diagonal
		if((Math.abs(start.getFile() - end.getFile())) == (Math.abs(start.getRank() - end.getRank()))) {
			int x = start. getFile();
			//check if going down
			if(start.getRank() < end.getRank()) {
				//check if going down to the left 
				if(start.getFile() > end.getFile()) {
					x -= 1;
					for(int i = start.getRank()+1; i <= end.getRank(); i++){
						if(b.getPosition(i, x).isOccupied() && 
								!b.getPosition(i, x).equals(end)){
							return false;
						}
						x--;
					}
				}
				//checks if going down to the right
				else {
					x += 1;
					for(int i = start.getRank()+1; i <= end.getRank(); i++){
						if(b.getPosition(i,x).isOccupied() && 
								!b.getPosition(i,x).equals(end)){
							return false;
						}
						x++;
					}
				}
				
			}
			//check if going up
			else
			{	
				//check if going up to the left
				if(start.getFile() > end.getFile()) {
					x -= 1;
					for(int i = start.getRank()-1; i >= end.getRank(); i--){
						if(b.getPosition(i,x).isOccupied() && 
								!b.getPosition(i, x).equals(end)){
							return false;
						}
						x--;
					}
					
				}
				//checks if going up to the right
				else {
					x+=1;
					for(int i = start.getRank()-1; i >= end.getRank(); i--){
						if(b.getPosition(i, x).isOccupied() && 
								!b.getPosition(i,x).equals(end)){
							return false;
						}
						x++;
					}
				}
				
			}
			return true;
		}
		return false;
	}


}
