import json
import requests
import webbrowser
import spotipy
from spotipy import *
#from spotipy.oauth2 import SpotifyClientCredentials

username = ''
clientID = ''
clientSecret = ''
redirect_uri = 'http://127.0.0.1:9090'

oauth_object = spotipy.SpotifyOAuth(clientID, clientSecret, redirect_uri)
token_dict = oauth_object.get_cached_token()
token = token_dict['access_token']
sp = spotipy.Spotify(auth=token)
user_name = sp.current_user()

SPOTIFY_GET_CURRENT_TRACK_URL = 'https://api.spotify.com/v1/me/player/currently-playing'

# To print the response in readable format.
#print(json.dumps(user_name, sort_keys=True, indent=4))

print(token)



# song = input ("Input song: ")
# mySearch = sp.search(song)

#print(mySearch)

# spotipy.prompt_for_user_token(username='akon(hs)', scope='user-read-currently-playing', client_id=clientID, client_secret=clientSecret, redirect_uri=redirect_uri)


# Get current playback song

def get_current_track(token):
        response = requests.get(
            SPOTIFY_GET_CURRENT_TRACK_URL,
            headers={
                "Authorization": "Bearer {token}"
            }
        )
        resp_json = response.json()

        current_track_info = {
            "id": track_id,
            "name": track_name,
            "artist": artist_name,
            "link": link
        }

        return current_track_info

def main():
        current_track_info = get_current_track(token)

        print(current_track_info)


if __name__ == '__main__':
    main()
