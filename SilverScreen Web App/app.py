from flask import Flask, render_template, json, jsonify, request, redirect, session, url_for
import requests, sqlite3, os
from functools import wraps
import hashlib

app = Flask(__name__)
OMDB_API_KEY = '52dce214'
app.secret_key = '83476982749528498-SILVERSCREEN_PLAYLISTS_2025'
mySalt = "silverscreen-2025"

def hash(salt, str):
    fullStr = salt + str
    return hashlib.sha256(fullStr.encode()).hexdigest()

def init_db():
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            username TEXT PRIMARY KEY,
            password TEXT NOT NULL,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            email TEXT NOT NULL,
            UNIQUE (username, email)
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS movie_likes (
            movie_key TEXT PRIMARY KEY,
            title TEXT,
            poster TEXT,
            year TEXT,
            total_likes INTEGER DEFAULT 0
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS user_likes (
            username TEXT,
            movie_key TEXT,
            PRIMARY KEY (username, movie_key),
            FOREIGN KEY (movie_key) REFERENCES movie_likes(movie_key)
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS playlists (
            username TEXT NOT NULL,
            playlist_id INTEGER PRIMARY KEY AUTOINCREMENT,
            playlist_name TEXT NOT NULL,
            playlist_data JSON NOT NULL,
            UNIQUE (username, playlist_name),
            FOREIGN KEY (username) REFERENCES users(username) ON DELETE CASCADE
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS playlist_likes (
            playlist_id INTEGER PRIMARY KEY,
            playlist_name TEXT,
            created_by TEXT,
            total_likes INTEGER DEFAULT 0   
        ) 
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS user_playlist_likes (
            username TEXT,
            playlist_id INTEGER,
            PRIMARY KEY (username, playlist_id),
            FOREIGN KEY (playlist_id) REFERENCES playlist_likes(playlist_id)
        )
    ''')

    conn.commit()
    conn.close()

init_db()

def login_required(f):
    @wraps(f)
    def ensure_login(*args, **keyword_args):
        if not session.get('logged_in'):
            return redirect(url_for('first'))
        return f(*args, **keyword_args)
    return ensure_login

@app.route('/')
def first():
    return render_template("first_page.html")

@app.route('/index')
@login_required
def index():
    return render_template("index.html")

@app.route('/search')
@login_required
def searchpage():
    return render_template("searchpage.html") 

@app.route('/menu')
@login_required
def menu():
    return render_template('menu.html')

@app.route('/profile')
@login_required
def profile():
    return render_template('profile.html')

@app.route('/makeplaylists')
@login_required
def makeplaylists():
    return render_template('makeplaylists.html')

@app.route('/getUsername')
@login_required
def getUsername():
    print(session['username'])
    return session['username']

@app.route('/search/<searchInput>')
@login_required
def search(searchInput):
    url = f"http://www.omdbapi.com/?apikey={OMDB_API_KEY}&s={searchInput}"
    data = requests.get(url).text
    return data

@app.route('/searchPlaylists/<searchInput>')
@login_required
def searchPlaylists(searchInput):
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    try:
        cursor.execute('''
            SELECT playlist_id, playlist_name, playlist_data, username
            FROM playlists
            WHERE playlist_name LIKE ?
        ''', (f'%{searchInput}%',))
        
        playlists = cursor.fetchall()
        
        results = []
        for playlist in playlists:
            results.append({
                'playlist_id': playlist[0],
                'playlist_name': playlist[1],
                'playlist_data': playlist[2],
                'created_by': playlist[3]
            })
        
        return jsonify({'success': True, 'playlists': results})
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500
    finally:
        conn.close()

@app.route('/playlist/<playlist_id>')
@login_required
def playlist_details(playlist_id):
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute('SELECT username, playlist_name, playlist_data FROM playlists WHERE playlist_id = ?', (playlist_id,))
    playlist = cursor.fetchone()
    conn.close()
    movie_data = json.loads(playlist[2]) if playlist else {'movies': []}
    return render_template('playlist_display.html', user=playlist[0], playlist_name=playlist[1], movie_data=movie_data)

@app.route('/movie/<imdb_id>')
@login_required
def movie_details(imdb_id):
    url = f"http://www.omdbapi.com/?apikey={OMDB_API_KEY}&i={imdb_id}"
    data = requests.get(url).text
    return data

@app.route('/submitPlaylist', methods=['POST'])
@login_required
def submitPlaylist():
    data = request.get_json()
    username = data['username']
    playlist_name = data['playlist_name']
    playlist_data = json.dumps(data['playlist_data'])

    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO playlists (username, playlist_name, playlist_data)
            VALUES (?, ?, ?)
        """, (username, playlist_name, playlist_data))
        conn.commit()
        return jsonify({'success': True, 'message': 'Playlist created successfully'})
    except sqlite3.IntegrityError:
        return jsonify({'success': False, 'message': 'Unable to create playlist'}), 400
    finally:
        conn.close()
        
@app.route('/signUp', methods=['POST'])
def signUp():
    data = request.get_json()
    first_name = data['first_name']
    last_name = data['last_name']
    email = data['email']
    username = data['username']
    password = data['password']
    hashword = hash(mySalt, password)

    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO users (first_name, last_name, email, username, password)
            VALUES (?, ?, ?, ?, ?)
        """, (first_name, last_name, email, username, hashword))
        conn.commit()
        return jsonify({'success': True, 'message': 'User registered successfully'})
    except sqlite3.IntegrityError:
        return jsonify({'success': False, 'message': 'Username or email already exists'}), 400
    finally:
        conn.close()

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data['username']
    password = data['password']
    hashword = hash(mySalt, password)

    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE username = ? AND password = ?", (username, hashword))
    user = cursor.fetchone()
    conn.close()

    if user:
        session['logged_in'] = True
        session['username'] = username
        return jsonify({'success': True, 'message': "Login Successful"})
    else:
        return jsonify({'success': False, 'message':"Username or Password is incorrect"})
    
@app.route('/logout')
@login_required
def logout():
    session.pop('username', None)
    session.pop('logged_in', None)
    return redirect(url_for('first'))

@app.route('/loginCheck')
def loginCheck():
    return jsonify({'login': session.get('logged_in', False)})
    
@app.route('/like_movie', methods=['POST'])
@login_required
def like_movie():
    data = request.get_json()
    username = session.get('username')
    if not username:
        return jsonify({'success': False, 'message': 'Not logged in'}), 401

    key = data['key']
    title = data['title']
    poster = data['poster']
    year = data['year']

    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    cursor.execute("SELECT 1 FROM user_likes WHERE username = ? AND movie_key = ?", (username, key))
    already_liked = cursor.fetchone()

    try:
        if already_liked:
            cursor.execute("DELETE FROM user_likes WHERE username = ? AND movie_key = ?", (username, key))
            cursor.execute("UPDATE movie_likes SET total_likes = total_likes - 1 WHERE movie_key = ?", (key,))
            conn.commit()
            return jsonify({'success': True, 'liked': False})
        else:
            cursor.execute("SELECT 1 FROM movie_likes WHERE movie_key = ?", (key,))
            exists = cursor.fetchone()

            if (exists):
                cursor.execute("UPDATE movie_likes SET total_likes = total_likes + 1 WHERE movie_key = ?", (key,))
            else:
                cursor.execute("INSERT INTO movie_likes (movie_key, title, poster, year, total_likes) VALUES (?, ?, ?, ?, 1)",
                           (key, title, poster, year))

            cursor.execute("INSERT INTO user_likes (username, movie_key) VALUES (?, ?)", (username, key))
            conn.commit()
            return jsonify({'success': True})
    finally:
        conn.close()

@app.route('/movie_likes/<key>')
@login_required
def get_movie_likes(key):
    username = session.get('username')
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    
    cursor.execute("SELECT total_likes FROM movie_likes WHERE movie_key = ?", (key,))
    result = cursor.fetchone()
    total_likes = result[0] if result else 0

    cursor.execute("SELECT 1 FROM user_likes WHERE username = ? AND movie_key = ?", (username, key))
    liked = cursor.fetchone() is not None

    conn.close()
    return jsonify({'likes': total_likes, 'liked': liked})

@app.route('/top_movies')
@login_required
def top_movies():
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute("SELECT title, poster, year, movie_key, total_likes FROM movie_likes ORDER BY total_likes DESC LIMIT 8")
    rows = cursor.fetchall()
    conn.close()
    movies = [
        {'title': row[0], 'poster': row[1], 'year': row[2], 'key': row[3], 'likes': row[4]}
        for row in rows
    ]
    return jsonify(movies)

@app.route('/top_playlists')
@login_required
def top_playlists():
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute('''
        SELECT p.playlist_id, p.playlist_name, p.username, p.playlist_data, pl.total_likes
        FROM playlists p
        JOIN playlist_likes pl ON p.playlist_id = pl.playlist_id
        ORDER BY pl.total_likes DESC
        LIMIT 4
    ''')
    rows = cursor.fetchall()
    conn.close()
    playlists = [
        {'playlist_id': row[0], 'playlist_name': row[1], 'created_by': row[2], 'playlist_data': row[3], 'total_likes': row[4]}
        for row in rows
    ]
    return jsonify(playlists)


@app.route('/like_playlist', methods=['POST'])
@login_required
def like_playlist():
    data = request.get_json()
    username = session.get('username')
    playlist_id = data['playlist_id']
    playlist_name = data['playlist_name']
    created_by = data['created_by']

    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    cursor.execute("SELECT 1 FROM user_playlist_likes WHERE username = ? AND playlist_id = ?", (username, playlist_id))
    already_liked = cursor.fetchone()

    try:
        if already_liked:
            cursor.execute("DELETE FROM user_playlist_likes WHERE username = ? AND playlist_id = ?", (username, playlist_id))
            cursor.execute("UPDATE playlist_likes SET total_likes = total_likes - 1 WHERE playlist_id = ?", (playlist_id,))
            conn.commit()
            return jsonify({'success': True, 'liked': False})
        else:
            cursor.execute("SELECT 1 FROM playlist_likes WHERE playlist_id = ?", (playlist_id,))
            exists = cursor.fetchone()
            if (exists):
                cursor.execute("UPDATE playlist_likes SET total_likes = total_likes + 1 WHERE playlist_id = ?", (playlist_id,))
            else:
                cursor.execute("""
                    INSERT INTO playlist_likes (playlist_id, playlist_name, created_by, total_likes)
                    VALUES (?, ?, ?, 1)
                """, (playlist_id, playlist_name, created_by))

            cursor.execute("""
                INSERT INTO user_playlist_likes (username, playlist_id)
                VALUES (?, ?)
            """, (username, playlist_id))
            conn.commit()
            return jsonify({'success': True})
    finally:
        conn.close()

@app.route('/playlist_likes/<int:playlist_id>')
@login_required
def get_playlist_likes(playlist_id):
    username = session.get('username')
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    cursor.execute("SELECT total_likes FROM playlist_likes WHERE playlist_id = ?", (playlist_id,))
    result = cursor.fetchone()
    total_likes = result[0] if result else 0

    cursor.execute("SELECT 1 FROM user_playlist_likes WHERE username = ? AND playlist_id = ?", (username, playlist_id))
    liked = cursor.fetchone() is not None

    conn.close()
    return jsonify({'likes': total_likes, 'liked': liked})


@app.route('/user_liked_movies')
@login_required
def user_liked_movies():
    username = session.get('username')
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute('''
        SELECT m.title, m.poster, m.year, m.movie_key
        FROM movie_likes m
        JOIN user_likes u ON m.movie_key = u.movie_key
        WHERE u.username = ?
    ''', (username,))

    movies = [
        {'title': row[0], 'poster': row[1], 'year': row[2], 'key': row[3]}
        for row in cursor.fetchall()
    ]
    conn.close()
    return jsonify(movies)

@app.route('/user_liked_playlists')
@login_required
def user_liked_playlists():
    username = session.get('username')
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    cursor.execute('''
        SELECT p.playlist_id, p.playlist_name, p.playlist_data, p.username
        FROM playlists p
        JOIN user_playlist_likes upl ON p.playlist_id = upl.playlist_id
        WHERE upl.username = ?
    ''', (username,))

    playlists = [
        {
            'playlist_id': row[0],
            'playlist_name': row[1],
            'playlist_data': row[2],
            'created_by': row[3]
        }
        for row in cursor.fetchall()
    ]
    conn.close()
    return jsonify(playlists)

@app.route('/user_created_playlists')
@login_required
def user_created_playlists():
    username = session.get('username')
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute('''
        SELECT playlist_id, playlist_name, playlist_data, username
        FROM playlists
        WHERE username = ?
    ''', (username,))

    playlists = [
        {
            'playlist_id': row[0],
            'playlist_name': row[1],
            'playlist_data': row[2],
            'created_by': row[3]
        }
        for row in cursor.fetchall()
    ]
    conn.close()
    return jsonify(playlists)

@app.route('/edit_playlist/<playlist_id>')
@login_required
def edit_playlist(playlist_id):
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute('SELECT playlist_name, playlist_data FROM playlists WHERE playlist_id = ?', (playlist_id,))
    playlist = cursor.fetchone()
    conn.close()
    return render_template('makeplaylists.html', playlist_name=playlist[0], playlist_data=playlist[1], playlist_id=playlist_id)

@app.route('/update_playlist', methods=['PUT'])
@login_required
def update_playlist():
    data = request.get_json()
    playlist_id = data['playlistId']
    playlist_name = data['title']
    playlist_data = json.dumps(data['playlist_data'])
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    try:
        cursor.execute('UPDATE playlists SET playlist_name = ?, playlist_data = ? WHERE username = ? AND playlist_id = ? ', 
                   (playlist_name, playlist_data, session['username'], playlist_id))
        conn.commit()
        return jsonify({'success': True, 'message': 'Playlist updated successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 400
    finally:
        conn.close()
    

if __name__ == '__main__':
    app.run()
