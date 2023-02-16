let access_token=""

setInterval(function(){
    callAjax();
    }, 1000);
    var apiData; 
    var audioData;  
    var callAjax = function(){
     $.ajax({
        url: 'https://api.spotify.com/v1/me/player/currently-playing',
        headers: {
          'Authorization': 'Bearer ' + access_token
        },
        success: function(response) {
          currentPlayingPlaceholder.innerHTML = currentPlayingTemplate(response);

          apiData = response;
          console.log(response);
          $('#login').hide();
          $('#loggedin').show();
        }
    });
    if(apiData != undefined){
    $.ajax({
        url: "https://api.spotify.com/v1/audio-features/" + apiData.item.id,
        //url: "https://api.spotify.com/v1/audio-features/06AKEBrKUckW0KREUWRnvT",
        headers: {
          'Authorization': 'Bearer ' + access_token
        },
        success: function(response) {
          audioFeaturesPlaceholder.innerHTML = audioFeaturesTemplate(response);

          //audioData = response;                  
          console.log(response);
          $('#login').hide();
          $('#loggedin').show();
        }
    });
}}