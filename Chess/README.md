<h1>Chess -- in Java (Hackathon 2022)</h1>

<h2>Description</h2>
The prompt of this Hackathon challenge was to create a collaborative project using ONLY Java in three days. I worked with a team including myself and two others.
<br />


<h2>Languages and Utilities Used</h2>

- <b>Java</b> 
- <b>Built in Java Graphics</b>
- <b>Microsoft Paint</b>

<h2>Program walk-through:</h2>

<p align="center">
The Pieces: <br/>
<p align="left">
&nbsp;&nbsp;&nbsp;&nbsp;Each piece inherits from a 'Piece.java' abstract class, which outlines common features and methods that will need to be tracked
for each piece, such as color, name, if piece is captured, if piece can move to a particular square, and if piece is the same color as another piece. Then, 
each piece has its own class that extends the abstract class and overrides the canMove method according to the logic of each piece. Some pieces also have 
additional methods to keep track of their unique properties, such as the pawn being able to move two spaces on its first move and the king not being able
to move into check.
</p>
<br/>
</p>
<p align="center">
Creating the board: <br/>
<p align="left">
&nbsp;&nbsp;&nbsp;&nbsp; The actual graphics of the board were created under the strict limitations of using only Java. A 2D array of JButtons is used, with images
placed over them for the pieces. The choice of buttons was used to make selecting a piece easier, as we can use an actionEventListener to check for clicks. Under
the hood, a 2D array of Positions mirroring the board is used to track where the pieces are relative to the individual buttons. The position class deals with
an individual position on the board, denoted by rank and file variables. A position can check which piece -- if any -- is on that rank and file. At the start of each game, each image is placed on its starting JButton, and the virtual version of the piece is placed on its appropriate position.
</p>
<br/>
</p>
<p align="center">
Moving the pieces: <br/>
<p align="left">
&nbsp;&nbsp;&nbsp;&nbsp; Moving the pieces on the board was definitely a challenge. First, we had to keep track of clicks on the screen. The JButtons were particularly useful for this, as we could use an actionEventListener. What was tricky was that we needed to keep track of a second click on the board for where the piece was going to be moving. To keep track of this, we used an sPress (second press) boolean variable, and stored the virtual position of the source and destination of the clicks (checking to see if there was a piece to move from the square of the first click) in fPos and tPos variables (from Position and to Position). From here we can start moving the piece, with a few special cases to cover -- such as the king attempting to castle or moving into check. Luckily, the logic for the majority of cases was pretty simple: check the piece being moved's canMove method and if true update the image of the piece to the button at tPos. Last, we have to update the state of the game after the move is complete. This means checking for checkmate, calling the toString() method to display the chess notation of the move on the screen, and updating the first move variable if the piece was a king, rook, or pawn. We also included the option to flip the board on the screen for co-op gaming, but commented it out for the time being.
</p>
<br/>
</p>
<p align="center">
 <br/>
<p align="left">
&nbsp;&nbsp;&nbsp;&nbsp; 
</p>
<br/>
</p>

<!--
 ```diff
- text in red
+ text in green
! text in orange
# text in gray
@@ text in purple (and bold)@@
```
--!>
