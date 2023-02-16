import requests

# pip3 install python-dotenv
from dotenv import load_dotenv
load_dotenv()

import os

from pprint import pprint


SPOTIFY_GET_AUDIO_FEATURES = 'https://api.spotify.com/v1/audio-features?ids=6o8nZVzweaEOLDLOgaogX5'
ACCESS_TOKEN_BPM = os.environ.get("ACCESS_TOKEN_BPM")


def get_current_track(ACCESS_TOKEN_BPM):
    response = requests.get(
        SPOTIFY_GET_AUDIO_FEATURES,
        headers={
            "Authorization": f"Bearer {ACCESS_TOKEN_BPM}"
        }
    )
    json_resp_features = response.json()

    song_features = json_resp_features['audio_features']


    current_track_features = {
    	"Features": song_features
    }

    return current_track_features


def main():
	current_track_features = get_current_track(ACCESS_TOKEN_BPM)
	pprint(current_track_features)


if __name__ == '__main__':
    main()