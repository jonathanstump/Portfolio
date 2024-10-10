<h1>Chess -- in Java (Hackathon 2022)</h1>

<h2>Description</h2>
The prompt of this Hackathon challenge was to create a collaborative project using ONLY Java in three days.
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
an individual position on the board, denoted by rank and file variables. A position can check which piece -- if any -- is on that rank and file. 
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
