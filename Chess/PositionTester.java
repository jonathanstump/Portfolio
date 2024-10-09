public class PositionTester {

	public static void main(String args[]) {
		Board b = new Board();
		Queen wQ = new Queen(true);
		Queen bQ = new Queen(false);
		Rook wR = new Rook(true);
		Rook bR = new Rook(false);
		Rook bR2 = new Rook(false);
		Rook bR3 = new Rook(false);
		Bishop wB = new Bishop(true);
		Bishop bB = new Bishop(false);
		Knight wK = new Knight(false);
		King wKing = new King(true);
		Pawn pawn1 = new Pawn(true);
		Pawn pawn2 = new Pawn(false);
		
		Position p1 = new Position(7,3, bQ);
		//Position p2 = new Position(1,0, wQ);
		//Position p3 = new Position(1,5, null);
		//Position p4 = new Position(3,0, bR);
		Position p11 = new Position(7,2, bR2);
		Position p12 = new Position(7,4, bR3);
		Position p5 = new Position(0,4, bB);
		//Position p6 = new Position(3,6, wK);
		
		Position p7 = new Position(2,3, wKing);
		//Position p8 = new Position(1,4, pawn2);
		//Position p9 = new Position(6,4, pawn1);
		//Position p10 = new Position(6,5, null);
		
		
		b.setPosition(p1, p1.getRank(), p1.getFile());
		//b.setPosition(p2, p2.getRank(), p2.getFile());
		//b.setPosition(p3, p3.getRank(), p3.getFile());
		//b.setPosition(p4, p4.getRank(), p4.getFile());
		b.setPosition(p5, p5.getRank(), p5.getFile());
		//b.setPosition(p6, p6.getRank(), p6.getFile());
		b.setPosition(p7, p7.getRank(), p7.getFile());
		System.out.println(b.getPosition(7, 1).toString());
		//b.setPosition(p8, p8.getRank(), p8.getFile());
		//b.setPosition(p9, p9.getRank(), p9.getFile());
		//b.setPosition(p10, p10.getRank(), p10.getFile());
		b.setPosition(p11, p11.getRank(), p11.getFile());
		b.setPosition(p12, p12.getRank(), p12.getFile());
		//System.out.println(p2.getPiece());
		//System.out.println(q.equals(p2));
		//System.out.println(q.toString());
//		System.out.println(wKing.isChecked(b,p7,p6));
		//System.out.println(p1.getPiece().canMove(b,p1,p10));
		//System.out.println(p6.getPiece().canMove(b, p6, p3));
		System.out.println(wKing.checkMate(b, p7));
		//System.out.println(q.checkForPiece(p1));
	}
}
