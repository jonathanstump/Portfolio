package ChessPackage;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.Shape;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BoxLayout;
import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JTextArea;
/**
 * Authors: Jonathan Stump, Tyler Lintker
 * Jace Akerman
 * This is the single greatest chess game known to man.
 * Take a moment and appreciate it.
 *
 */
public class Board extends JFrame implements ActionListener{

	private JButton[][] squares = new JButton[8][8];
	private int yeet;
	private Position[][] myBoard; 
	private JPanel panel = new JPanel();
	private JPanel panel2 = new JPanel();
	private JPanel panel3 = new JPanel();
	private JTextArea text = new JTextArea();
	private JFrame frame = new JFrame("Chess");
	private Position fPos;
	private Position tPos;
	private boolean sPress = false;
	private Queen wQueen = new Queen(true);
	private Queen bQueen = new Queen(false);
	private King wKing = new King(true);
	private King bKing = new King(false);
	private Piece wPawn = new Pawn(true);
	private Piece wPawn2 = new Pawn(true);
	private Piece wPawn3 = new Pawn(true);
	private Piece wPawn4 = new Pawn(true);
	private Piece wPawn5 = new Pawn(true);
	private Piece wPawn6 = new Pawn(true);
	private Piece wPawn7 = new Pawn(true);
	private Piece wPawn8 = new Pawn(true);
	private Piece bPawn = new Pawn(false);
	private Piece bPawn2 = new Pawn(false);
	private Piece bPawn3 = new Pawn(false);
	private Piece bPawn4 = new Pawn(false);
	private Piece bPawn5 = new Pawn(false);
	private Piece bPawn6 = new Pawn(false);
	private Piece bPawn7 = new Pawn(false);
	private Piece bPawn8 = new Pawn(false);
	private Piece wKnight = new Knight(true);
	private Piece wKnight2 = new Knight(true);
	private Piece bKnight = new Knight(false);
	private Piece bKnight2 = new Knight(false);
	private Piece wBishop = new Bishop(true);
	private Piece wBishop2 = new Bishop(true);
	private Piece bBishop = new Bishop(false);
	private Piece bBishop2 = new Bishop(false);
	private Rook wRook = new Rook(true);
	private Rook wRook2 = new Rook(true);
	private Rook bRook = new Rook(false);
	private Rook bRook2 = new Rook(false);
	private boolean whiteMove = true;
	private int turnNum = 1;
	private boolean castleKS = false;
	private boolean castleQS = false;
	
	public Board() {
		int temp = 0;
		panel.setLayout(new GridLayout(1,2));
		panel2.setLayout(new GridLayout(8,8));
		panel3.setLayout(new GridLayout(1,1));
		panel3.add(text);
		//panel.add(panel2);
		myBoard = new Position[8][8];
		for(int r = 0; r < myBoard.length; r++) {
			if(r % 2 !=0)
			{
				temp = 1;
			}
			else
			{
				temp = 0;
			}
			for(int c=0; c<myBoard[0].length; c++) {
				myBoard[r][c] = new Position(r,c, null);
				squares[r][c] = new JButton();
				squares[r][c].addActionListener(this);
				if(temp % 2 != 0)
				{
					squares[r][c].setBackground(Color.ORANGE);
				}
				else
				{
					squares[r][c].setBackground(Color.WHITE);
				}
				panel2.add(squares[r][c]);
				temp++;
			}
		}
		this.setGame();
		//Dimension dic
		panel2.setPreferredSize(getPreferredSize());
		panel.add(panel2);
		panel.add(panel3);
		frame.add(panel);
		frame.pack();
		frame.setVisible(true);
	}
	
	public Board(int x)
	{
		yeet = x;
	}
	
	public void setGame()
	{
		this.setKings();
		this.setQueens();
		this.setRooks();
		this.setKnights();
		this.setBishops();
		this.setPawns();
	}
	
	public void setKings()
	{
		ImageIcon i = new ImageIcon("wking.jpg.jpg");
		squares[7][4].setIcon(i);
		myBoard[7][4].setPiece(wKing);
		ImageIcon x = new ImageIcon("bking.jpg");
		squares[0][4].setIcon(x);
		myBoard[0][4].setPiece(bKing);
	}
	
	public void setQueens()
	{
		ImageIcon i = new ImageIcon("wqueen.jpg");
		squares[7][3].setIcon(i);
		myBoard[7][3].setPiece(wQueen);
		ImageIcon x = new ImageIcon("bqueen.jpg");
		squares[0][3].setIcon(x);
		myBoard[0][3].setPiece(bQueen);
	}
	
	public void setRooks()
	{
		ImageIcon i = new ImageIcon("wRook.jpg");
		squares[7][0].setIcon(i);
		myBoard[7][0].setPiece(wRook);
		ImageIcon x = new ImageIcon("wRook.jpg");
		squares[7][7].setIcon(x);
		myBoard[7][7].setPiece(wRook2);
		ImageIcon y = new ImageIcon("bRook.jpg");
		squares[0][0].setIcon(y);
		myBoard[0][0].setPiece(bRook);
		ImageIcon z = new ImageIcon("bRook.jpg");
		squares[0][7].setIcon(z);
		myBoard[0][7].setPiece(bRook2);
	}
	
	public void setKnights()
	{
		ImageIcon i = new ImageIcon("wknight.png");
		squares[7][1].setIcon(i);
		myBoard[7][1].setPiece(wKnight);
		ImageIcon x = new ImageIcon("wknight.png");
		squares[7][6].setIcon(x);
		myBoard[7][6].setPiece(wKnight2);
		ImageIcon y = new ImageIcon("bknight.png");
		squares[0][1].setIcon(y);
		myBoard[0][1].setPiece(bKnight);
		ImageIcon z = new ImageIcon("bknight.png");
		squares[0][6].setIcon(z);
		myBoard[0][6].setPiece(bKnight2);
	}
	
	public void setBishops()
	{
		ImageIcon i = new ImageIcon("wbishop.jpg");
		squares[7][2].setIcon(i);
		myBoard[7][2].setPiece(wBishop);
		ImageIcon x = new ImageIcon("wbishop.jpg");
		squares[7][5].setIcon(x);
		myBoard[7][5].setPiece(wBishop2);
		ImageIcon y = new ImageIcon("bbishop.jpg");
		squares[0][2].setIcon(y);
		myBoard[0][2].setPiece(bBishop);
		ImageIcon z = new ImageIcon("bbishop.jpg");
		squares[0][5].setIcon(z);
		myBoard[0][5].setPiece(bBishop2);
	}
	
	public void setPawns()
	{
		ImageIcon i = new ImageIcon("wpawn.png");
		squares[6][0].setIcon(i);
		myBoard[6][0].setPiece(wPawn);
		ImageIcon x = new ImageIcon("wpawn.png");
		squares[6][1].setIcon(x);
		myBoard[6][1].setPiece(wPawn2);
		ImageIcon y = new ImageIcon("wpawn.png");
		squares[6][2].setIcon(y);
		myBoard[6][2].setPiece(wPawn3);
		ImageIcon z = new ImageIcon("wpawn.png");
		squares[6][3].setIcon(z);
		myBoard[6][3].setPiece(wPawn4);
		ImageIcon a = new ImageIcon("wpawn.png");
		squares[6][4].setIcon(a);
		myBoard[6][4].setPiece(wPawn5);
		ImageIcon b = new ImageIcon("wpawn.png");
		squares[6][5].setIcon(b);
		myBoard[6][5].setPiece(wPawn6);
		ImageIcon c = new ImageIcon("wpawn.png");
		squares[6][6].setIcon(c);
		myBoard[6][6].setPiece(wPawn7);
		ImageIcon d = new ImageIcon("wpawn.png");
		squares[6][7].setIcon(d);
		myBoard[6][7].setPiece(wPawn8);
		
		ImageIcon e = new ImageIcon("bpawn.png");
		squares[1][0].setIcon(e);
		squares[1][1].setIcon(e);
		squares[1][2].setIcon(e);
		squares[1][3].setIcon(e);
		squares[1][4].setIcon(e);
		squares[1][5].setIcon(e);
		squares[1][6].setIcon(e);
		squares[1][7].setIcon(e);
		myBoard[1][0].setPiece(bPawn);
		myBoard[1][1].setPiece(bPawn2);
		myBoard[1][2].setPiece(bPawn3);
		myBoard[1][3].setPiece(bPawn4);
		myBoard[1][4].setPiece(bPawn5);
		myBoard[1][5].setPiece(bPawn6);
		myBoard[1][6].setPiece(bPawn7);
		myBoard[1][7].setPiece(bPawn8);
	}
	
	public void actionPerformed(ActionEvent e)
	{
		for(int r = 0; r< myBoard.length; r++)
		{
			for(int c = 0; c< myBoard[0].length; c++)
			{
				if(sPress == false)
				{
					if(e.getSource() == squares[r][c])
					{
						fPos = myBoard[r][c];
						if(myBoard[r][c].getPiece()!=null)
						{
							sPress = true;
						}
					}
				}
				else
				{
					if(e.getSource() == squares[r][c])
					{
						tPos = myBoard[r][c];
						sPress = false;
						this.movePiece(fPos, tPos, fPos.getPiece(), whiteMove);
					}
				}
			}
		}
		
	}
	
	public void movePiece(Position f, Position t, Piece p, boolean b)
	{
		if(f.equals(t))
		{
			return;
		}
		
		if(p instanceof King)
		{
			if(f.getRank() == t.getRank() && (int)Math.abs(f.getFile()-t.getFile())== 2)
			{
				if(!putSelfInCheck(null, null, whiteMove))
				{
					castle(f,t);
					((King)p).setFM(false);
					return;
				}
				return;
			}
		}
		
		if((p.canMove(this, f, t)) && (p.isWhite() == whiteMove))
		{
			if(putSelfInCheck(t, f, whiteMove))
			{
				return;
			}
			boolean capture;
			if(t.getPiece() != null)
			{
				capture = true;
			}
			else
			{
				capture = false;
			}
			myBoard[t.getRank()][t.getFile()].setPiece(myBoard[f.getRank()][f.getFile()].getPiece());
			myBoard[f.getRank()][f.getFile()].setPiece(null);
			squares[t.getRank()][t.getFile()].setIcon(squares[f.getRank()][f.getFile()].getIcon());
			squares[f.getRank()][f.getFile()].setIcon(null);
			
			if(isCheckmate(t, f, whiteMove))
			{
				String temp = text.getText();
				temp += this.toString(t, f, p, capture, wKing.isChecked(this, findPosition(wKing, myBoard), t), true);
				temp += '\n';
				if(whiteMove) {
					temp += "white wins lol";
				}
				else
				{
					temp += "black wins lol";
				}
				text.setText(temp);
			}
			else if(whiteMove) {
				String temp = text.getText();
				temp += this.toString(t, f, p, capture, bKing.isChecked(this, findPosition(bKing, myBoard), t), false);
				text.setText(temp);
			}
			else
			{
				String temp = text.getText();
				temp += this.toString(t, f, p, capture, wKing.isChecked(this, findPosition(wKing, myBoard), t), false);
				temp += '\n';
				text.setText(temp);
			}
			//flip();
			
			whiteMove = !whiteMove;
			if(p instanceof Pawn)
			{
				((Pawn) p).setFirstMove(false);
				promotion(t, !whiteMove);
			}
			if(p instanceof Rook)
			{
				((Rook) p).setFirstMove(false);
			}
			if(p instanceof King)
			{
				((King) p).setFM(false);
			}
		}
	}
	
//	public void flip()
//	{
//		JButton[][] tempB = squares;
//		Position[][] tempP = myBoard;
//		for(int r = 0; r< myBoard.length/2; r++)
//		{
//			for(int c = 0; c< myBoard[0].length; c++)
//			{
//				swap(squares[7-r][7-c],squares[r][c]);
//				swap(myBoard[7-r][7-c],myBoard[r][c]);
//			}
//		}
//		
//		
//	}
//	
//	public void swap(JButton a, JButton b)
//	{
//		JButton temp = new JButton();
//		temp.setIcon(a.getIcon());
//		a.setIcon(b.getIcon());
//		b.setIcon(temp.getIcon());
//	}
//	
//	public void swap(Position a, Position b)
//	{
//		Position temp = new Position();
//		temp.setPiece(a.getPiece());
//		a.setPiece(b.getPiece());
//		b.setPiece(temp.getPiece());
//		
//	}
	
	public int getRows() {
		return myBoard.length;
	}
	
	public int getCols() {
		return myBoard[0].length;
	}
//	
//	public boolean outOfBounds(Piece e) {
//		if(0 < e.getMyPosition().getRank() || e.getMyPosition().getRank() > getRows() 
//				&& 0 < e.getMyPosition().getFile() || e.getMyPosition().getFile() > getCols()) {
//			return true;
//		}
//		return false;
//	}
		
	
	public String toString() {
		String temp = " ";
	
		for(int r = 0; r < myBoard.length; r++) {
			
			for(int c = 0; c<myBoard[0].length; c++) {
				
			
				temp = temp + myBoard[r][c].toString() +" ";	
			}
		}
			temp = temp+ "\n";
		
		return temp;
	}
	public Position getPosition(int r, int f) {
		return myBoard[r][f];
	}
	

	
	public void setPosition(Position p, int x, int y) {
		myBoard[x][y] = p;
	}

	public String toString(Position pos, Position og, Piece p, boolean capture, boolean inCheck, boolean checkmate)
	{
		String temp = "";
		if(p == null)
		{
			return temp;
		}
		if(castleKS)
		{
			temp += "0-0";
		}
		if(castleQS)
		{
			temp += "0-0-0";
		}
		if(whiteMove)
		{
			if(p instanceof Queen)
			{
				temp += "Q";
			}
			else if(p instanceof King && (!castleKS && !castleQS))
			{
				temp += "K"; 
			}
			else if(p instanceof Rook)
			{
				temp += "R";
			}
			else if(p instanceof Knight)
			{
				temp += "N";
			}
			else if(p instanceof Bishop)
			{
				temp += "B";
			}
		}
		else
		{
			if(p instanceof Queen)
			{
				temp += "Q";
			}
			else if(p instanceof King && (!castleKS && !castleQS))
			{
				temp += "K";
			}
			else if(p instanceof Rook)
			{
				temp += "R";
			}
			else if(p instanceof Knight)
			{
				temp += "N";
			}
			else if(p instanceof Bishop)
			{
				temp += "B";
			}
			turnNum++;
		}
		if(castleKS||castleQS)
		{
			castleKS = false;
			castleQS = false;
			if(whiteMove)
			{
				return ""+turnNum + ". " + temp;
			}
			return " " + temp;
		}
		if((capture) && !(p instanceof Pawn))
		{
			temp += "x";
			int file = pos.getFile();
			Character c = new Character((char) ('a' +file));
			temp+= c;
		}
		else if(!(p instanceof Pawn))
		{
			int file = pos.getFile();
			Character c = new Character((char) ('a' +file));
			temp+= c;
		}
		else if((capture) && (p instanceof Pawn))
		{
			int file2 = og.getFile();
			Character c2 = new Character((char) ('a' +file2));
			temp+= c2;
			temp += "x";
			int file = pos.getFile();
			Character c = new Character((char) ('a' +file));
			temp+= c;
			temp += (8-pos.getRank());
		}
		else if((p instanceof Pawn))
		{
			int file = pos.getFile();
			Character c = new Character((char) ('a' +file));
			temp+= c;
			temp += (8-pos.getRank());
		}
		if(!(p instanceof Pawn))
		{
			if(whiteMove) {
				if(inCheck && !checkmate)
				{
					return ""+turnNum +". " +temp +(8-pos.getRank()) +"+";
				}
				else if(checkmate)
				{
					return ""+turnNum +". " +temp +(8-pos.getRank()) +"#";
				}
				return ""+turnNum +". " +temp +(8-pos.getRank());
			}
			if(inCheck && !checkmate)
			{
				return " "+temp +(8-pos.getRank()) +"+";
			}
			else if(checkmate)
			{
				return " "+temp +(8-pos.getRank()) +"#";
			}
			return " " +temp +(8-pos.getRank());
		}
		else
		{
			if(whiteMove) {
				if(inCheck && !checkmate)
				{
					return ""+turnNum +". "+temp +"+";
				}
				else if(checkmate)
				{
					return ""+turnNum +". "+temp +"#";
				}
				return ""+turnNum +". "+temp;
			}
			if(inCheck && !checkmate)
			{
				return " "+temp +"+";
			}
			else if(checkmate)
			{
				return " "+temp +"#";
			}
			return " " +temp;
		}
	}
	
	private Position findPosition(Piece p, Position[][] temp) {
		for(int r=0; r<myBoard.length; r++)
		{
			for(int c=0; c<myBoard[0].length; c++)
			{
				if(temp[r][c].getPiece() != null)
				{
					if(temp[r][c].getPiece().equals(p))
					{
						return temp[r][c];
					}
				}
			}
		}
		return null;
	}
	
	public Position[][] getMyBoard()
	{
		return myBoard;
	}
	
	public void setMyBoard(Position[][] p)
	{
		myBoard = p;
	}
	
	private boolean putSelfInCheck(Position to, Position from, boolean wm)
	{
		Board temp1 = new Board(3);
		Position[][] temp = new Position[8][8];
		for(int r=0; r<myBoard.length; r++)
		{
			for(int c=0; c<myBoard[0].length; c++)
			{
				if(myBoard[r][c].getPiece() != null)
				{
					temp[r][c] = new Position(r,c, myBoard[r][c].getPiece());
				}
				else
				{
					temp[r][c] = new Position(r,c, null);
				}
			}
		
		}
		temp1.setMyBoard(temp);
	//	System.out.println(temp[from.getRank()][from.getFile()].toString());
	//	System.out.println(temp[to.getRank()][to.getFile()].toString());
		if(from != null) {
			temp[to.getRank()][to.getFile()].setPiece(null);
			temp[to.getRank()][to.getFile()].setPiece(temp[from.getRank()][from.getFile()].getPiece());
			temp[from.getRank()][from.getFile()].setPiece(null);
		}
	//	System.out.println("1"+temp[to.getRank()][to.getFile()].toString());
	//	System.out.println(temp[from.getRank()][from.getFile()].toString());
		
		boolean x = false;
		for(int r=0; r<myBoard.length; r++)
		{
			for(int c=0; c<myBoard[0].length; c++)
			{
				if(temp[r][c].getPiece() != null)
				{
					if(wm)
					{
						if(temp[r][c].getPiece().canMove(temp1, findPosition(temp[r][c].getPiece(), temp), findPosition(wKing, temp)))
						{
							 return true;
						}
					}
					else
					{
						if(temp[r][c].getPiece().canMove(temp1, findPosition(temp[r][c].getPiece(), temp), findPosition(bKing, temp)))
						{
							 return true;
						}
					}
					
				}
			}
		}
		return x;
	}
	
	private boolean isCheckmate(Position to, Position from, boolean wm)
	{
		if(wm) {
			
				for(int r=0; r<myBoard.length; r++)
				{
					for(int c=0; c<myBoard[0].length; c++)
					{
						if(myBoard[r][c].getPiece() != null)
						{
							if(!myBoard[r][c].getPiece().isWhite())
							{
								for(int x=0; x<myBoard.length; x++)
								{
									for(int y=0; y<myBoard[0].length; y++)
									{
										if(myBoard[r][c].getPiece().canMove(this, findPosition(myBoard[r][c].getPiece(), myBoard), myBoard[x][y]))
										{
											if(!putSelfInCheck(myBoard[x][y], findPosition(myBoard[r][c].getPiece(), myBoard), !wm))
											{
												return false;
											}
										}
									}
								}
							}
						}
					}
				}
		}
		else
		{
			if(!wm) {
				
				for(int r=0; r<myBoard.length; r++)
				{
					for(int c=0; c<myBoard[0].length; c++)
					{
						if(myBoard[r][c].getPiece() != null)
						{
							if(myBoard[r][c].getPiece().isWhite())
							{
								for(int x=0; x<myBoard.length; x++)
								{
									for(int y=0; y<myBoard[0].length; y++)
									{
										if(myBoard[r][c].getPiece().canMove(this, findPosition(myBoard[r][c].getPiece(), myBoard), myBoard[x][y]))
										{
											if(!putSelfInCheck(myBoard[x][y], findPosition(myBoard[r][c].getPiece(), myBoard), !wm))
											{
												return false;
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		return true;
			
	}
	
	private boolean canCastle(Rook r, King k)
	{
		if(r.isWhite()!=whiteMove || k.isWhite() != whiteMove)
		{
			return false;
		}
		if(r.getFirstMove()==false || k.getFM()==false)
		{
			return false;
		}
		if(whiteMove)
		{
			Position p = findPosition(wKing, myBoard);
			if(r==wRook2)
			{
				for(int i=0; i<2; i++)
				{
					if(myBoard[p.getRank()][p.getFile()+i+1].isOccupied())
					{
						return false;
					}
					if(putSelfInCheck(myBoard[p.getRank()][p.getFile()+i+1], p, whiteMove))
					{
						return false;
					}
				}
				return true;
			}
			if(r==wRook)
			{
				for(int i=0; i<2; i++)
				{
					if(myBoard[p.getRank()][p.getFile()-i-1].isOccupied())
					{
						return false;
					}
					if(putSelfInCheck(myBoard[p.getRank()][p.getFile()-i-1],p, whiteMove))
					{
						return false;
					}
				}
				if(myBoard[p.getRank()][p.getFile()-3].isOccupied())
				{
					return false;
				}
				return true;
			}
		}
		else
		{
			Position p = findPosition(bKing, myBoard);
			if(r==bRook2)
			{
				for(int i=0; i<2; i++)
				{
					if(myBoard[p.getRank()][p.getFile()+i+1].isOccupied())
					{
						return false;
					}
					if(putSelfInCheck(myBoard[p.getRank()][p.getFile()+i+1],p, whiteMove))
					{
						return false;
					}
				}
				return true;
			}
			if(r==bRook)
			{
				for(int i=0; i<2; i++)
				{
					if(myBoard[p.getRank()][p.getFile()-i-1].isOccupied())
					{
						return false;
					}
					if(putSelfInCheck(myBoard[p.getRank()][p.getFile()-i-1],p, whiteMove))
					{
						return false;
					}
				}
				if(myBoard[p.getRank()][p.getFile()-3].isOccupied())
				{
					return false;
				}
				return true;
			}
		}
		return false;
	}
	
	private void castle(Position f, Position t)
	{
		if(f.getRank()==t.getRank()&&(int)Math.abs(f.getFile()-t.getFile())==2)
		{
			if(whiteMove)
			{
				if(f.getFile()-t.getFile()==-2)
				{
					if(canCastle(wRook2, wKing))
					{
						myBoard[7][6].setPiece(wKing);
						myBoard[7][4].setPiece(null);
						squares[7][6].setIcon(squares[7][4].getIcon());
						squares[7][4].setIcon(null);
						myBoard[7][5].setPiece(wRook2);
						myBoard[7][7].setPiece(null);
						squares[7][5].setIcon(squares[7][7].getIcon());
						squares[7][7].setIcon(null);
						castleKS = true;
						String temp = text.getText();
						temp += this.toString(t, f, wKing, false, false, false);
						text.setText(temp);
						whiteMove = !whiteMove;
						return;
					}
				}
				else
				{
					if(canCastle(wRook, wKing))
					{
						myBoard[7][2].setPiece(wKing);
						myBoard[7][4].setPiece(null);
						squares[7][2].setIcon(squares[7][4].getIcon());
						squares[7][4].setIcon(null);
						myBoard[7][3].setPiece(wRook);
						myBoard[7][0].setPiece(null);
						squares[7][3].setIcon(squares[7][7].getIcon());
						squares[7][0].setIcon(null);
						castleQS = true;
						String temp = text.getText();
						temp += this.toString(t, f, wKing, false, false, false);
						text.setText(temp);
						whiteMove = !whiteMove;
						return;
						
					}
				}
			}
			else
			{
				if(t.getFile()-f.getFile()==2)
				{
					if(canCastle(bRook2, bKing))
					{
						myBoard[0][6].setPiece(bKing);
						myBoard[0][4].setPiece(null);
						squares[0][6].setIcon(squares[0][4].getIcon());
						squares[0][4].setIcon(null);
						myBoard[0][5].setPiece(bRook2);
						myBoard[0][7].setPiece(null);
						squares[0][5].setIcon(squares[0][7].getIcon());
						squares[0][7].setIcon(null);
						castleKS = true;
						String temp = text.getText();
						temp += this.toString(t, f, bKing, false, false, false);
						text.setText(temp);
						whiteMove = !whiteMove;
						return;
						
					}
				}
				else
				{
					if(canCastle(bRook, bKing))
					{
						myBoard[0][2].setPiece(bKing);
						myBoard[0][4].setPiece(null);
						squares[0][2].setIcon(squares[0][4].getIcon());
						squares[0][4].setIcon(null);
						myBoard[0][3].setPiece(bRook);
						myBoard[0][0].setPiece(null);
						squares[0][3].setIcon(squares[0][0].getIcon());
						squares[0][0].setIcon(null);
						castleQS = true;
						String temp = text.getText();
						temp += this.toString(t, f, bKing, false, false, false);
						text.setText(temp);
						whiteMove = !whiteMove;
						return;
						
					}
				}
			}
		}
		
	}
	
	private void promotion(Position at, boolean whiteMove)
	{
		if(at.getRank() == 0 || at.getRank() == 7)
		{
			at.setPiece(new Queen(whiteMove));
		}
	}
}
